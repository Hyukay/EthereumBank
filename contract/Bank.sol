
pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import '@openzeppelin/contracts/interfaces/IERC20.sol';




contract Bank{
    
    struct account{
        bool exists;
        uint256 balance;
    }

    mapping(address => account) private accounts;

    modifier AccountExists{
        
        require(accounts[msg.sender].exists, "No Account found for this address");
        _;
    }

    function OpenAccount() external payable {

        require(!accounts[msg.sender].exists, "Account already exists");
        accounts[msg.sender].exists = true;
        accounts[msg.sender].balance = msg.value;
    }
    function closeAccount() public {

        require(accounts[msg.sender].balance == 0, "The account has funds");

        delete(accounts[msg.sender]);
    }
    
    function depositETH() public payable AccountExists {
        
        accounts[msg.sender].balance += msg.value;
    }
    
    function withdrawETH(uint256 _amount) public AccountExists {

        if(_amount > accounts[msg.sender].balance) {

            _amount = accounts[msg.sender].balance;
        }
        
        accounts[msg.sender].balance -= _amount;
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Withdrawal failed");
    }

    function getBalance() public view returns (uint256) {

        return accounts[msg.sender].balance;
    }
      
 






}