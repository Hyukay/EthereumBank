
pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import '@openzeppelin/contracts/interfaces/IERC20.sol';


contract ExtendedBank {
    
    struct account{
        bool exists;
        address[] tokens;
        mapping(address => uint256) balances;
    }

    mapping(address => account) private accounts;

    modifier AccountExists{
        
        require(accounts[msg.sender].exists, "No Account found for this address");
        _;
    }

    function OpenAccount(address tokenAdress, uint256 amount) external payable {

        require(!accounts[msg.sender].exists, "Account already exists");
        accounts[msg.sender].exists = true;

        //L
        if(tokenAdress == address(0)) {
           
           accounts[msg.sender].balances[address(0)] = msg.value;
           
        }
        else {
           
           require(msg.value==0, "Do not send ether when trying to deposit other ERC20 tokens at the same time");
           accounts[msg.sender].balances[tokenAdress] = amount;
           IERC20(tokenAdress).transferFrom(msg.sender, address(this), amount);
         
        }
    }
    function closeAccount() external AccountExists {
        
        for(uint i=0; i<accounts[msg.sender].tokens.length; i++) {
            //Loops through all tokens in the account to see if there are any tokens left to withdraw
           require(accounts[msg.sender].balances[accounts[msg.sender].tokens[i]] == 0, "The account has funds");
           delete(accounts[msg.sender]);
          
        }
        
    }
    
    function deposit(address tokenAddress, uint256 amount) external payable AccountExists {
        
        if(tokenAddress == address(0)) {
           
           accounts[msg.sender].balances[address(0)] += amount;
           
        }
        else {

            require(msg.value == 0, "Do not send ether when trying to deposit other ERC20 tokens at the same time");

            if(tokenExist(msg.sender, tokenAddress) == false){
           
            accounts[msg.sender].tokens.push(tokenAddress);
            accounts[msg.sender].balances[tokenAddress] += amount;

           }
           else {

           accounts[msg.sender].balances[tokenAddress] += amount;

            }
           IERC20(tokenAddress).transferFrom(msg.sender,address(this), amount);
         
        }
 
    }
    
    function withdraw(address tokenAddress, uint256 amount) external AccountExists {

        // If users try to withdraw more than they have, empty their bank account
        if(amount> accounts[msg.sender].balances[tokenAddress]) {
           
          amount = accounts[msg.sender].balances[tokenAddress];
          
        }
        else {
            accounts[msg.sender].balances[tokenAddress] -= amount;
        }              
        if(tokenAddress == address(0)) {
           
           (bool success, ) = payable(msg.sender).call{value: amount}("");
           require(success, "Withdrawal failed");
           
        }
        else {
           
           IERC20(tokenAddress).transferFrom(address(this), msg.sender, amount);
          
        }
      
    }

    function getBalance(address account,address tokenAddress) external view returns (uint256) {

        return accounts[account].balances[tokenAddress];
    }

    function tokenExist(address account, address tokenAddress) internal view returns (bool) {
        
        bool found; 

        for(uint i=0; i<accounts[account].tokens.length; i++) {
            //Loops through all tokens in the account to see if there are any tokens left to withdraw
           if(accounts[account].tokens[i] == tokenAddress) {
               found = true;
           }
           else {
               found = false;
           }
        }
     
        return found;
    }
      
    






}