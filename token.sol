pragma solidity ^0.8.2;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract B10 is ERC20 {
  constructor() ERC20('BSC 10 LARGE CAP', 'B10') {
    _mint(msg.sender, 1000000 * 10 ** 18);
  }
  
  //iBNB bnb = IBNB(0x73827478)
  //iETH eth = IETH(0x8980809808)
  //iSOL sol = iSOL(0x890880980809)
  //ratio_eth = 0.75
  //ratio_sol = 0.25
  
  // Possible de faire un mapping ? une sorte de array pour stocker les coins ? et les créer à la volée
  //map()
  
  //Quand on achete le token on achete les % correspondants 
  
  // On transfère les BNB token vers l'address de notre Token
  //bnb.TransferFrom(msg.sender, address(this), amount)
  
  //On crée un token B10 et on l'envoie au sender
  // _mint(mesg.sender, amount)
  
  // On transfère une commision vers le wallet de dev
  // bnb.TransferFrom(address(this), devWallet, amount)
  
  // On prend une commision pour les fees
  //bnb_to_invest = 0.99 * amount
  
  //next we need to allow the uniswapv2 router to spend the token we just sent to this contract
  //by calling IERC20 approve you allow the uniswap contract to spend the tokens in this contract 
  //IERC20(bnb).approve(UNISWAP_V2_ROUTER, _amountIn);
  
  //On swap chaque BNB dans les portions qui correspondent
  //path = new address[](2);
  //path[0] = bnb;
  //path[1] = eth
  //IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(0.75*bnb_to_invest, _amountOutMin, path, address(this), block.timestamp);
  
  //path = new address[](2);
  //path[0] = bnb;
  //path[1] = sol
  //IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(0.25*bnb_to_invest, _amountOutMin, path, address(this), block.timestamp);
  
  (map Token => map())
  
  
  
  
  // Quand le user veut retirer on doit convertir les fonds en BNB
  
  //Quand un user nous envoi un B10 token, capturer les events ?
  
  //amount_B10_sent
  //on prend une commision de 1% pour couvrir les frais (com fixe ?)
  //amount_B10_to_redeem = 0.99 * amount_B10_sent
  
  //On doit convertir les token en BNB
  //path = new address[](2);
  //path[0] = eth;
  //path[1] = bnb
  //IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(0.75*amount_B10_to_redeem, _amountOutMin, path, address(this), block.timestamp);
  
  //path = new address[](2);
  //path[0] = sol;
  //path[1] = bnb
  //IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(0.25*amount_B10_to_redeem, _amountOutMin, path, address(this), block.timestamp);
  
  //On envoie les BNB au user 
  //bnb.Transfer(msg.sender, bnb_token_amount)
  
  //On burn le token de l'user
  //_burn(msg.sender, amount)
  
  
  //fuction decreaseDevFee(uint newFee) external admin{if newFee < 0.01 : devFee = newFee}
  
  //fuction decreaseComFee(uint ComFee) external admin{if newFee < 0.01 : ComFee = newFee}
  
  //fuction glisemmentPercent(uint newPercent) external admin(glissPrecent = newPercent)
  
  //Fuction activeBalance(bool active) external admin{auto_balance = active}
  
  //Function auto_balance(){if (balance) get cap from API and update pourcentage si le % de change est supérieur à 2%}
  
  //Function progressiveBuy pour ne pas déstabiliser le market si trop gros volume
  
  //Function progressiveSell poun ne pas déstabiliser le marché (il faut prendre un random)
  
  
  
  
  
  
}