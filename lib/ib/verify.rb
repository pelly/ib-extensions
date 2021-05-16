module IB
	# define a custom ErrorClass which can be fired if a verification fails
#	class VerifyError < StandardError
#	end

  class Contract

    # IB::Contract#Verify

    # verifies the contract
    #
    # returns the number of contracts returned by the TWS.
    #
    #
    # The method accepts a block. The  queried contract-Object is accessible there.
    # If multiple contracts are specified, the block is executed with each of these contracts.
    #
    #
    # Verify returns an  _Array_ of contracts. The  operation leaves the contract untouched.
    # 
    #
    # Returns nil if the contract could not be verified.
    #
    #	 > s =  Stock.new symbol: 'AA'
    #     => #<IB::Stock:0x0000000002626cc0
    #        @attributes={:symbol=>"AA", :con_id=>0, :right=>"", :include_expired=>false,
    #                     :sec_type=>"STK", :currency=>"USD", :exchange=>"SMART"}
    #  > sp  = s.verify.first.essential
    #     => #<IB::Stock:0x00000000025a3cf8
    #        @attributes={:symbol=>"AA", :con_id=>251962528, :exchange=>"SMART", :currency=>"USD",
    #                     :strike=>0.0, :local_symbol=>"AA", :multiplier=>0, :primary_exchange=>"NYSE",
    #                     :trading_class=>"AA", :sec_type=>"STK", :right=>"", :include_expired=>false}
    #
    #  > s =  Stock.new symbol: 'invalid'
    #     =>  @attributes={:symbol=>"invalid", :sec_type=>"STK", :currency=>"USD", :exchange=>"SMART"}
    #  >  sp  = s.verify
    #     => []
    #
    # Takes a Block to modify the queried contracts
    #
    # f = Future.new  symbol: 'M2K'  
    # con_ids =  f.verify{ |c| c.con_id }
    #   [412889018, 428519982, 446091466, 461318872, 477836981] 
    #
    #
    # Parameter: thread: (true/false)
    #
    # If multiple contracts are to be verified, they can be queried simultaneously.
    #    IB::Symbols::W500.map{|c|  c.verify(thread: true){ |vc| do_something }}.join

    def verify thread: nil, &b
      return [self] if contract_detail.present? || sec_type == :bag
      _verify update: false, thread: thread,  &b  # returns the allocated threads
    end # def

    # returns a hash
    def nessesary_attributes

      v= { stock:  { currency: 'USD', exchange: 'SMART', symbol: nil},
           option: { currency: 'USD', exchange: 'SMART', right: 'P', expiry: nil, strike: nil, symbol:  nil},
           future: { currency: 'USD', exchange: nil, expiry: nil,  symbol: nil },
           forex:  { currency: 'USD', exchange: 'IDEALPRO', symbol: nil }
      }
      sec_type.present? ?	v[sec_type] : { con_id: nil, exchange: 'SMART' } # enables to use only con_id for verifying
																																				# if the contract allows SMART routing
    end

    #
    #   depreciated:  Do not use  anymore
    def verify!
      c =  0
      IB::Connection.logger.warn "Contract.verify! is depreciated. Use \"contract =  contract.verify.first\" instead"
      _verify( update: true){| response | c+=1 } # wait for the returned thread to finish
      IB::Connection.logger.error { "Multible Contracts detected during verify!."  } if c > 1
      self
    end

		private

    # Base method to verify a contract
    #
    # if :thread is given, the method subscribes to messages, fires the request and returns the thread, that
    # receives the exit-condition-message
    #
    # otherwise the method waits until the response form tws is processed
    #
    #
    # if :update is true, the attributes of the Contract itself are adapted
    #
    # otherwise the Contract is untouched
    def _verify thread: nil , update:,  &b # :nodoc:
      ib = Connection.current
      # we generate a Request-Message-ID on the fly
      message_id = nil
      # define local vars which are updated within the query-block
      recieved_contracts = []
      queue = Queue.new
      a = nil

      # a tws-request is suppressed for bags and if the contract_detail-record is present
      tws_request_not_nessesary = bag? || contract_detail.is_a?( ContractDetail )

      if tws_request_not_nessesary
        yield self if block_given?
        return self
      else # subscribe to ib-messages and describe what to do
        a = ib.subscribe(:Alert, :ContractData,  :ContractDataEnd) do |msg|
          case msg
          when Messages::Incoming::Alert
            if msg.code == 200 && msg.error_id == message_id
              ib.logger.error { "Not a valid Contract :: #{self.to_human} " }
              queue.close
            end
          when Messages::Incoming::ContractData
            if msg.request_id.to_i == message_id
              # if multiple contracts are present, all of them are assigned
              # Only the last contract is saved in self;  'count' is incremented
              ## a specified block gets the contract_object on any unique ContractData-Event
              recieved_contracts << if block_given?
                                      yield msg.contract
              else
                msg.contract
              end
              if update
                self.attributes = msg.contract.attributes
                self.contract_detail = msg.contract_detail unless msg.contract_detail.nil?
              end
            end
          when Messages::Incoming::ContractDataEnd
            queue.push(1) if  msg.request_id.to_i == message_id

          end  # case
        end # subscribe

        ### send the request !
        #	contract_to_be_queried =  con_id.present? ? self : query_contract
        # if no con_id is present,  the given attributes are checked by query_contract
        #	if contract_to_be_queried.present?   # is nil if query_contract fails
        message_id = ib.send_message :RequestContractData, :contract => query_contract

        th =  Thread.new do
          queue.pop
#          j=0; loop{ sleep(0.01);  j+=1; break if queue.closed? || queue.pop || j> 100; }
#          ib.logger.error{ "#{to_human} --> No ContractData recieved " } if j >= 100 && !queue.closed?
          ib.unsubscribe a
        end
        if thread.nil?
          th.join    # wait for the thread to finish
          recieved_contracts			 # return queue of contracts
        else
          th			# return active thread
        end
      end
    end

    # Generates an IB::Contract with the required attributes to retrieve a unique contract from the TWS
    #
    # Background: If the tws is queried with a »complete« IB::Contract, it fails occasionally.
    # So – even to update its contents, a defined subset of query-parameters  has to be used.
    #
    # The required data-fields are stored in a yaml-file and fetched by #YmlFile.
    #
    # If `con_id` is present, only `con_id` and `exchange` are transmitted to the tws.
    # Otherwise a IB::Stock, IB::Option, IB::Future or IB::Forex-Object with necessary attributes
    # to query the tws is build (and returned)
    #
    # If Attributes are missing, an IB::VerifyError is fired,
    # This can be trapped with 
    #   rescue IB::VerifyError do ...

    def  query_contract( invalid_record: true )  # :nodoc:
      # don't raise a verify error at this time. Contract.new con_id= xxxx, currency = 'xyz' is also valid
      ##	raise VerifyError, "Querying Contract failed: Invalid Security Type" unless SECURITY_TYPES.values.include? sec_type

      ## the yml contains symbol-entries
      ## these are converted to capitalized strings
      items_as_string = ->(i){i.map{|x,y| x.to_s.capitalize}.join(', ')}
      ## here we read the corresponding attributes of the specified contract
      item_values = ->(i){ i.map{|x,y| self.send(x).presence || y }}
      ## and finally we create a attribute-hash to instantiate a new Contract
      ## to_h is present only after ruby 2.1.0
      item_attributehash = ->(i){ i.keys.zip(item_values[i]).to_h }
      ## now lets proceed, but only if no con_id is present
      if con_id.blank? || con_id.zero?
        #				if item_values[necessary_attributes].any?( &:nil? )
        #					raise VerifyError, "#{items_as_string[necessary_attributes]} are needed to retrieve Contract,
        #																	got: #{item_values[necessary_attributes].join(',')}"
        #				end
        #			Contract.build  item_attributehash[necessary_items].merge(:sec_type=> sec_type)  # return this
        Contract.build  self.invariant_attributes # return this
      else   # its always possible, to retrieve a Contract if con_id and exchange  or are present
        Contract.new  con_id: con_id , :exchange => exchange.presence || item_attributehash[nessesary_attributes][:exchange].presence || 'SMART'				# return this
      end  # if
    end # def
  end
end #module
