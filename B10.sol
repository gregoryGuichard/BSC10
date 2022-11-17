// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';



contract B10 is ERC20 {
    
    uint rate = 100;
    
  constructor()  ERC20('BSC10 smart contract', 'B10') {
    _mint(msg.sender, 100 * 10 ** 18);
  }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {
         _mint(msg.sender, msg.value * rate);
    }

    // Fallback function is called when msg.data is not empty
    fallback() external payable {
        _mint(msg.sender, 100 * 10 **18);
    }
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        if (recipient == address(this)){
            _burn(msg.sender, amount);
            sendViaCall(msg.sender, amount/ (rate));
        }
        else{
            _transfer(_msgSender(), recipient, amount);
        }
        return true;
    }
    
      function sendViaCall(address  _to, uint256 amount) public payable {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent, bytes memory data) = _to.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
  
  