// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Test, console } from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BargelToken} from "../src/BargelToken.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";


contract MerkleAirdropTest is Test, ZkSyncChainChecker {
    MerkleAirdrop public airdrop;
    BargelToken public token;
    bytes32 public ROOT = 0x738917418657cc378ed9816b6c070443ef9b52f15191f09496819ab0269de917;
    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18;
    bytes32 proofOne = 0x7309c9ef128ee6afed1bbe69f4583f8ffa15a5f50328260277042a2e6122e070;
    bytes32 proofTwo = 0xfcee8b2f100d3056bdb7cc78f74c043bf07d3e95f1472413049cc5ed37c62ee0;
    uint256 public AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
    bytes32[] public PROOF = [proofOne, proofTwo];
    address public gasPayer;    //新增气体支付者
    address user;
    uint256 userPrivKey;


    function setUp() public {
       
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        }else{    
            token = new BargelToken();
            airdrop = new MerkleAirdrop(ROOT,token);
            token.mint(token.owner(), AMOUNT_TO_SEND);
            token.transfer(address(airdrop), AMOUNT_TO_SEND);
        }
        (user, userPrivKey) = makeAddrAndKey("user");   
        gasPayer = makeAddr("gasPayer");
    }


    function testUserCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);

        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending Balance:", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);

    }
    
}