// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { MerkleAirdrop, IERC20 } from "../src/MerkleAirdrop.sol";
import { Script } from "forge-std/Script.sol";
import { BargelToken } from "../src/BargelToken.sol";
import { console } from "forge-std/console.sol";


contract DeployMerkleAirdrop is Script{
    bytes32 private s_merkleRoot = 0x738917418657cc378ed9816b6c070443ef9b52f15191f09496819ab0269de917;
    uint256 private s_amountToTransfer = 4 * 25 * 1e18;

    function deployMerkleAirdrop() public returns (MerkleAirdrop, BargelToken) {
        vm.startBroadcast();
        BargelToken token = new BargelToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(s_merkleRoot, IERC20(address(token)));
        token.mint(token.owner(), s_amountToTransfer);
        token.transfer(address(airdrop), s_amountToTransfer);
        vm.stopBroadcast();
        return (airdrop, token);

    }

    function run() external returns (MerkleAirdrop,BargelToken){
        return deployMerkleAirdrop();
    }
}