// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@chainlink/contracts/src/v0.7/interfaces/AggregatorV3Interface.sol";
//import the ERC20 interface

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


//import the uniswap router
//the contract needs to use swapExactTokensForTokens
//this will allow us to import swapExactTokensForTokens into our contract

interface IUniswapV2Router {
  function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);
  
  function swapExactTokensForTokens(
  
    //amount of tokens we are sending in
    uint256 amountIn,
    //the minimum amount of tokens we want out of the trade
    uint256 amountOutMin,
    //list of token addresses we are going to trade in.  this is necessary to calculate amounts
    address[] calldata path,
    //this is the address we are going to send the output tokens to
    address to,
    //the last time that the trade is valid for
    uint256 deadline
  ) external returns (uint256[] memory amounts);
  
  function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
        
   function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
}

interface IUniswapV2Pair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;
}

interface IUniswapV2Factory {
  function getPair(address token0, address token1) external returns (address);
}



contract tokenSwap {
    
    //address of the uniswap v2 router
    address private constant UNISWAP_V2_ROUTER = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
   
    address private constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    
    address private constant BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    
    address private constant WETH = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
    
    address private constant DAI = 0x8a9424745056Eb399FD19a0EC26A14316684e274;
    
    
    address private constant priceBnb = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526;
    
    address private constant priceBUSD = 0x9331b55D9830EF609A2aBCfAc0FBCE050A52fdEa;
    
    address private constant priceETH = 0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7;
    
    address private constant priceDAI = 0xE4eE17114774713d2De0eC0f035d4F7665fc025D;
    
    uint256 private sommeCapiWallet;
    
    uint256 private sommeCapiMarket;
    
    struct  CoinData {
        string symbol;
        address coinAddress;
        address priceFeedAddress;
        uint256 marketCapi;
        uint256 fundCapi;
    }
    
    CoinData[] public listCoins;
    
    constructor(){
        addCoin("BUSD", BUSD, priceBUSD);
        //addCoin("ETH", WETH, priceETH);
        addCoin("DAI", DAI, priceDAI);
        
    }
    
    
    
    AggregatorV3Interface internal priceFeed;
    
    
    function delCoin(string memory symbolToDel) public {
         for (uint i = 0; i < listCoins.length; i++) {
             CoinData memory coin = listCoins[i];
             if ( keccak256(bytes(coin.symbol)) == keccak256(bytes(symbolToDel))){
                 listCoins[i] = listCoins[listCoins.length - 1];
                 listCoins.pop();
             }
         }
    }
    
    function addCoin(string memory symbolToAdd, address coinAddress, address priceFeedAddress) public {
         CoinData memory coinToAdd;
         coinToAdd.symbol = symbolToAdd;
         coinToAdd.coinAddress = coinAddress;
         coinToAdd.priceFeedAddress = priceFeedAddress;
         listCoins.push(coinToAdd);
    }
    
    function getPositionOnToken(address coinAddress, address price) public view returns(uint){
        return IERC20(coinAddress).balanceOf(address(this)) * uint(getPrice(price));
    }
    
    function getWalletInfo() public{
        uint256 sommeCapi = 0;
        uint256 capiToken = 0;
        uint256 positionOnToken = 0;
        
        for (uint i = 0; i < listCoins.length; i++) {
            CoinData storage coin = listCoins[i];
            capiToken = getCapitalisation(coin.coinAddress, coin.priceFeedAddress);
            coin.marketCapi = capiToken;
            
            positionOnToken = getPositionOnToken(coin.coinAddress, coin.priceFeedAddress);
            coin.fundCapi = positionOnToken;
            sommeCapi += capiToken;
            sommeCapiWallet += positionOnToken;
        }
        sommeCapiMarket = sommeCapi;
    }
    
    function calculAmountToBuy(address priceFeedAddress, uint256 marketCapi, uint256 fundCapi) public view returns (uint256){
        uint256 currentPrice = uint(getPrice(priceFeedAddress));
        uint256 bnbToArbitre = address(this).balance;
        uint256 sommeCapiWalletBis = sommeCapiWallet + bnbToArbitre * uint256(getPrice(priceBnb));
        uint256 amountToBuy = 0;
        if (sommeCapiWalletBis > 0){
            if (marketCapi * sommeCapiWalletBis/ sommeCapiMarket   - fundCapi  > 0){
                 amountToBuy = (marketCapi * sommeCapiWalletBis/ sommeCapiMarket   - fundCapi )  / currentPrice;
            }
                }
        return amountToBuy;
    }
    
    function calculAmountToSell(address priceFeedAddress, uint256 marketCapi, uint256 fundCapi) public view returns (uint256){
        uint256 currentPrice = uint(getPrice(priceFeedAddress));
        uint256 bnbToArbitre = address(this).balance;
        uint256 sommeCapiWalletBis = sommeCapiWallet + bnbToArbitre * uint256(getPrice(priceBnb));
        uint256 amountToSell = 0;
        if (fundCapi > 0){
            if (fundCapi - marketCapi * sommeCapiWalletBis/ sommeCapiMarket > 0){
                 amountToSell = (fundCapi - marketCapi * sommeCapiWalletBis/ sommeCapiMarket )  / currentPrice;
            }
                }
        return amountToSell;
    }
    
    function arbitrage() public{
        uint ratioToHave = 0;
        uint currentRatio = 0;
        uint currentPrice = 0;
        // begin by sell token 
        for (uint i = 0; i < listCoins.length; i++) {
            CoinData memory coin = listCoins[i];
            uint amountToSell = calculAmountToSell(coin.priceFeedAddress, coin.marketCapi, coin.fundCapi);
            if (amountToSell > 0){
                sellToken(coin.coinAddress, amountToSell);
            }
        }
         for (uint i = 0; i < listCoins.length; i++) {
            CoinData memory coin = listCoins[i];
            uint amountToBuy = calculAmountToBuy(coin.priceFeedAddress, coin.marketCapi, coin.fundCapi);
            buyToken(coin.coinAddress, amountToBuy);
            if (amountToBuy > 0){
                buyToken(coin.coinAddress, amountToBuy);
            }
        }
    }
    
    function coordinate() public{
        uint bnbToArbitre = address(this).balance;
        getWalletInfo();
        sommeCapiWallet += bnbToArbitre * uint256(getPrice(priceBnb));
        arbitrage();
    }
    

    function getAmountOutMin(address _tokenIn, address _tokenOut, uint256 _amountIn) public view returns (uint256) {
        address[] memory path;
        path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;
        
        uint256[] memory amountOutMins = IUniswapV2Router(UNISWAP_V2_ROUTER).getAmountsOut(_amountIn, path);
        return amountOutMins[path.length -1];  
    }  
    
    receive() external payable {
        //uint256 amount = getAmountOutMin (WBNB, BUSD, msg.value);
        //address[] memory path = new address[](2);
        //path[0] = WBNB;
        //path[1] = BUSD;
    
        //IUniswapV2Router(UNISWAP_V2_ROUTER).swapETHForExactTokens{value: msg.value}(amount, path, address(this), block.timestamp);
        
        // refund leftover ETH to user
       //(bool sent, bytes memory data) =  msg.sender.call{value : address(this).balance} ("");
    }
    
    function sellToken(address _tokentoSell, uint256 _amountToSell) public{
        uint256 amount = getAmountOutMin (_tokentoSell, WBNB, _amountToSell);
        IERC20(_tokentoSell).approve(UNISWAP_V2_ROUTER, _amountToSell);
        address[] memory path = new address[](2);
        path[0] = _tokentoSell;
        path[1] = WBNB;
        IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForETH(_amountToSell, amount, path, address(this), block.timestamp);
       //(bool sent, bytes memory data) =  msg.sender.call{value : address(this).balance} ("");
    }
    
    function buyToken(address _tokentoBuy, uint256 _amountToBuy) public{
        uint256 amountBNB = getAmountOutMin (_tokentoBuy, WBNB, _amountToBuy);
        uint256 amount = getAmountOutMin (WBNB, _tokentoBuy, amountBNB);
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = _tokentoBuy;
    
        IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactETHForTokens{value: amountBNB}(amount, path, address(this), block.timestamp);
        
    }
    
    function getCapitalisation(address _token, address price) public view returns (uint256){
        return getTotalToken(_token) * uint(getPrice(price));
    }

    function getTotalToken(address _token) public view returns (uint256){
        return IERC20(_token).totalSupply();
    }
    
    function getPrice(address _token) public view returns (int){
        (uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = AggregatorV3Interface(_token).latestRoundData();
        return price;
    }
    


}