// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;

    /*
     * We will be using this below to help generate a random number
     */
    uint256 private seed;

    /*
     * This is an address => uint mapping, meaning I can associate an address with a number!
     * In this case, I'll be storing the address with the last time the user waved at us.
     */
    mapping(address => uint256) public lastWavedAt;

    mapping(address => uint) public waverFreq;

    mapping(address => uint) public popularity;

    struct Wave {
        address waver;
        address wavee;
        string messaege;
        uint timestamp;
    }

    event WaveCreated(address waver, address wavee, string messaege, uint timestamp);

    Wave[] public waves;

    constructor() payable {
        console.log("smart and local contract here!");

        /*
         * Set the initial seed
         */
        seed = (block.timestamp + block.difficulty) % 100;
    }

    function wave(address _address, string memory _message) public {
        /*
         * We need to make sure the current timestamp is at least 15-minutes bigger than the last timestamp we stored
         */
        require(
            lastWavedAt[msg.sender] + 30 seconds < block.timestamp,
            "Wait 30 seconds before waving again please"
        );

        /*
         * Update the current timestamp we have for the user
         */
        lastWavedAt[msg.sender] = block.timestamp;

        waverFreq[msg.sender]++;
        popularity[_address]++;
        totalWaves++;
        
        Wave memory w = Wave(msg.sender, _address, _message, block.timestamp);
        waves.push(w);

         /*
         * Generate a new seed for the next user that sends a wave
         */
        seed = (block.difficulty + block.timestamp + seed) % 100;
        console.log("seed: %s", seed);
        /*
         * Give a 50% chance that the user wins the prize.
         */
        if (seed <= 10) {
            console.log("%s won!", msg.sender);
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        console.log("%s has waved! and said: %s ", msg.sender, _message);
        emit WaveCreated(msg.sender, _address, _message, block.timestamp);
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }
    
    function getPopularity(address _address) public view returns (uint256) {
        console.log("%s has %d waves!", _address, popularity[_address]);
        return popularity[_address];
    }

    function getWaverFreq(address _address) public view returns (uint256) {
        console.log("%s has waved %d times!", _address, waverFreq[_address]);
        return waverFreq[_address];
    }

    function getWaves() public view returns (Wave[] memory) {
        console.log("%d waves!", waves.length);

        return waves;
    }
}