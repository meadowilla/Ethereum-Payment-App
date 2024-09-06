// SPDX-License-Identifier: UNLICENSED

// DO NOT MODIFY BELOW THIS
pragma solidity ^0.8.17;

import "hardhat/console.sol";

contract Splitwise {
// DO NOT MODIFY ABOVE THIS

// ADD YOUR CONTRACT CODE BELOW
    event AddNewUser(address user);
    event UpdateIOU(address debtor, address creditor, uint32 amount);
    event AddNewIOU(address debtor, address creditor, uint32 amount);

    mapping (address => mapping(address =>  uint32)) private IOUAmount;

    function lookup(address debtor, address creditor) public view returns (uint32 ret){
        return IOUAmount[debtor][creditor];
    }


    function add_IOU(address debtor, address creditor, uint32 amount, address[] memory directPath, address[] memory indirectPath) public {       
        // update_user(debtor, creditor);
        console.log("Hi, debtor: ", debtor);        

        if (directPath.length == 0){
            if (indirectPath.length == 0){ // new IOU
                console.log("new IOU");
                IOUAmount[debtor][creditor] = amount;
            } else if (indirectPath.length == 2){
                if (amount >= IOUAmount[creditor][debtor]){// replace
                    console.log("replace");
                    IOUAmount[debtor][creditor] = amount - IOUAmount[creditor][debtor];
                    IOUAmount[creditor][debtor] = 0;
                } else {// repay
                    console.log("repay");
                    IOUAmount[debtor][creditor] -= amount;
                }
            } else if (indirectPath.length > 2){// cycle
                console.log("cycle");
                uint32 minAmount;
                for (uint i=0; i<indirectPath.length-1; i++){
                    uint32 temp = IOUAmount[indirectPath[i]][indirectPath[i+1]];
                    if (i==0){
                        minAmount = temp;
                    }
                    if (minAmount > temp){
                        minAmount = temp;
                    }
                }
                if (minAmount > amount){
                    minAmount = amount;
                }

                for (uint i=0; i<indirectPath.length-1; i++){
                    IOUAmount[indirectPath[i]][indirectPath[i+1]] -= minAmount;
                }
                IOUAmount[debtor][creditor] = amount - minAmount;
            }
        } else if (directPath.length == 2){// owe more
            console.log("owe more");
            IOUAmount[debtor][creditor] += amount;
        }
        console.log("Bye");
        emit AddNewIOU(debtor, creditor, amount);
    }

}
