var EthereumLibrary = {
	$EthereumInterface: {},

	MyContract : 0,
	
	contractInstance : 0,

	InitContract : function (abi, address)
	{
		MyContract = web3.eth.contract(JSON.parse(Pointer_stringify(abi)));
		contractInstance = MyContract.at(address);	
	},
	
	Hello: function () {
    	window.alert("Hello, world!");
    },
  
  
    GetCurrentAccount : function ()
    {
		var returnStr = web3.eth.coinbase;
	    var bufferSize = lengthBytesUTF8(returnStr) + 1;
	    var buffer = _malloc(bufferSize);
	    stringToUTF8(returnStr, buffer, bufferSize);
	    return buffer;
    },

	GetCurrentOpponents : function (errorCallback, successCallback)
	{
		contractInstance.GetPlayersInteracting(function (error, response)
		{
			if (error)
			{
        		var buffer = getPtrFromString(error);
        		Runtime.dynCall('vi', errorCallback, [buffer]);
			}
			else 
			{
        		var buffer = getPtrFromString('Hello, world!');
        		Runtime.dynCall('vi', successCallback, [buffer]);
			/*
				var optn = new Option('Select Game', 0);
				if (response.length > 0)
				{
				    select.options.add(new Option('Select Game', select.options.length));
					for (var i = 0 ; i < response.length ; i++)
					{
	            		var optn = new Option(response[i], i+1);
				    	select.options.add(new Option(response[i], select.options.length));
					}
				}
			    select.options.add(new Option('New Game', select.options.length));
			    */
			}
		});
		
       
        function getPtrFromString(str) {
            var buffer = _malloc(lengthBytesUTF8(str) + 1);
            writeStringToMemory(str, buffer);
            return buffer;
        }
        
	},
	
    SimpleMethod: function(obj) {
   
        var buffer = getPtrFromString('Hello, world!');
        Runtime.dynCall('vi', obj, [buffer]);
       
        function getPtrFromString(str) {
            var buffer = _malloc(lengthBytesUTF8(str) + 1);
            writeStringToMemory(str, buffer);
            return buffer;
        }
    },
	
	GetCurrentGameState : function (opponent)
	{
		
	},
	
	InitiateGame : function (opponent, card, password)
	{
		
	},
	
	Answer : function (opponent, card)
	{
		
	},
	
	Reveal : function (opponent, password)
	{
		
	},

};


autoAddDeps(EthereumLibrary, '$EthereumInterface');

mergeInto(LibraryManager.library, EthereumLibrary);