// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    mapping(address => uint256) public lastWavedAt;
    mapping(address => uint256) public userWaves;
    address[] public topUsers;
    uint256 topWaverCount;
    uint256 private seed;

    event NewWave(address indexed from, uint256 timestamp, string message);

    /*
     * I created a struct here named Wave.
     * A struct is basically a custom datatype where we can customize what we want to hold inside it.
     */
    struct Wave {
        address waver; // The address of the user who waved.
        string message; // The message the user sent.
        uint256 timestamp; // The timestamp when the user waved.
    }

    /*
     * I declare a variable waves that lets me store an array of structs.
     * This is what lets me hold all the waves anyone ever sends to me!
     */
    Wave[] waves;

    constructor() payable {
        console.log("Yo yo, I am a contract and I am smart");

        seed = (block.timestamp + block.difficulty) % 100;
        
    }

    function wave(string memory _message) public {

        require(
            lastWavedAt[msg.sender] + 30 seconds < block.timestamp,
            "Wait 30 seconds!"
        );
        lastWavedAt[msg.sender] = block.timestamp;
        totalWaves += 1;
        userWaves[msg.sender] += 1;
        checkTop10(msg.sender);
        assignTop10(userWaves[msg.sender]);
        console.log("%s has waved!", msg.sender);

        waves.push(Wave(msg.sender, _message, block.timestamp));
        
        seed = (block.difficulty + block.timestamp + seed) % 100;
        console.log("Block difficulty: %d", block.difficulty);
        
        console.log("Random # generated: %d", seed);

        if (seed <= 50) {
            console.log("%s won!", msg.sender);

            /*
             * The same code we had before to send the prize.
             */
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }
    function getTopWaver() public view returns (address topWaver){
        ///@dev only assigns top 10
        console.log("Top Waver", topUsers[0]);
        console.log("Wave counts", userWaves[topUsers[0]]);
        return topUsers[0];
        
    }
    function getUserWaves(address _user) public view returns (uint256){
        return userWaves[_user];
    }
    function getTopWavers() public view returns (address[] memory topWavers){
        console.log("TopUsers", topUsers.length);
        
        
        return topUsers;
    }
    function assignTop10(uint256 _waves) internal {
        for(uint i = topUsers.length; i > 0; i--){
            if(_waves > userWaves[topUsers[i - 1]]){
                address temp = topUsers[i - 1];
                topUsers[i- 1] = topUsers[i];
                topUsers[i] = temp;
                console.log("topUsers Wave Counts: ", userWaves[topUsers[i - 1]]);
            }
            else{
                if(topUsers.length > 10){
                    topUsers.pop();
                }
                
                break;
            }
        }
        
        
    }
    function checkTop10(address _waver) internal {
        bool found;
        for(uint i = topUsers.length; i > 0; i--){
            if(_waver == topUsers[i - 1]){
                found = true;
            }
            else{
                found = false;
            }
        }
        if(!found){
            topUsers.push(_waver);
        }
    }
     function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }
}