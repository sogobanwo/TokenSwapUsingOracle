
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../contracts/SwapContract.sol";
import "../contracts/ERC20.sol";

contract SwapContractTest is Test {

    SwapContract swapContract;
    ERC20 dai;
    ERC20 link;
    ERC20 eth;

    address AddrEth = address(0xa);
    address AddrDai = address(0xb);
    address AddrLink = address(0xc);


    function setUp() public {
        dai = new ERC20("DAI", "D", 18);
        link = new ERC20("link", "l", 18);
        eth = new ERC20("eth", "e", 18);
        swapContract = new SwapContract(address(dai), address(eth), address(link));
        


        AddrEth = mkaddr("AddrEth");
        AddrDai = mkaddr("AddrDai");
        AddrLink = mkaddr("AddrLink");

        eth.mint(AddrEth, 1000000);
        dai.mint(AddrDai, 1000000);
        link.mint(AddrLink, 1000000);
        
    }

    function testBalances() public view {
        vm.assertEq(eth.balanceOf(AddrEth), 1000000);
        vm.assertEq(dai.balanceOf(AddrDai), 1000000);
        vm.assertEq(link.balanceOf(AddrLink), 1000000);
    }

    function testSwapEthDai() public {
        switchSigner(AddrDai);
        dai.transfer(address(swapContract), 900000);

        switchSigner(AddrEth);
        uint balanceOfDaiBeforeSwap = dai.balanceOf(AddrEth);
        eth.approve(address(swapContract), 1);

        swapContract.swapEthDai(1);

        uint balanceOfDaiAfterSwap = dai.balanceOf(AddrEth);

        assertGt(balanceOfDaiAfterSwap, balanceOfDaiBeforeSwap);

    }

     function testSwapEthLink() public {
        switchSigner(AddrLink);
        link.transfer(address(swapContract), 900000);

        switchSigner(AddrEth);
        uint balanceOfLinkBeforeSwap = link.balanceOf(AddrEth);
        eth.approve(address(swapContract), 1);

        swapContract.swapEthLink(1);

        uint balanceOflinkAfterSwap = link.balanceOf(AddrEth);

        assertGt(balanceOflinkAfterSwap, balanceOfLinkBeforeSwap);

    }

     function testSwapLinkDai() public {
        switchSigner(AddrDai);
        dai.transfer(address(swapContract), 900000);

        switchSigner(AddrLink);
        uint balanceOfDaiBeforeSwap = dai.balanceOf(AddrLink);
        link.approve(address(swapContract), 1);

        swapContract.swapLinkDai(1);

        uint balanceOfDaiAfterSwap = dai.balanceOf(AddrLink);

        assertGt(balanceOfDaiAfterSwap, balanceOfDaiBeforeSwap);

    }

     function testSwapLinkEth() public {
        switchSigner(AddrEth);
        eth.transfer(address(swapContract), 900000);

        switchSigner(AddrLink);
        uint balanceOfLinkBeforeSwap = eth.balanceOf(AddrLink);
        link.approve(address(swapContract), 1);

        swapContract.swapLinkEth(1);

        uint balanceOfLinkAfterSwap = eth.balanceOf(AddrLink);

        assertGt(balanceOfLinkAfterSwap, balanceOfLinkBeforeSwap);

    }

     function testSwapDaiLink() public {
        switchSigner(AddrLink);
        link.transfer(address(swapContract), 900000);

        switchSigner(AddrDai);
        uint balanceOfLinkBeforeSwap = link.balanceOf(AddrDai);
        dai.approve(address(swapContract), 1);

        swapContract.swapDaiLink(1);

        uint balanceOfLinkAfterSwap = link.balanceOf(AddrDai);

        assertGt(balanceOfLinkAfterSwap, balanceOfLinkBeforeSwap);

    }

     function testSwapDaiEth() public {
        switchSigner(AddrEth);
        eth.transfer(address(swapContract), 900000);

        switchSigner(AddrDai);
        uint balanceOfEthBeforeSwap = eth.balanceOf(AddrDai);
        dai.approve(address(swapContract), 1);

        swapContract.swapDaiEth(1);

        uint balanceOfEthAfterSwap = eth.balanceOf(AddrEth);

        assertGt(balanceOfEthAfterSwap, balanceOfEthBeforeSwap);

    }

    function mkaddr(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        return addr;
    }

    function switchSigner(address _newSigner) public {
        address foundrySigner = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
        if (msg.sender == foundrySigner) {
            vm.startPrank(_newSigner);
        } else {
            vm.stopPrank();
            vm.startPrank(_newSigner);
        }
    }

    
}



// HARDHAT TEST
// import {
//   time,
//   loadFixture,
// } from "@nomicfoundation/hardhat-toolbox/network-helpers";
// import { expect } from "chai";
// import { ethers } from "hardhat";

// describe("SwapToken", function () {
//   // We define a fixture to reuse the same setup in every test.
//   // We use loadFixture to run this setup once, snapshot that state,
//   // and reset Hardhat Network to that snapshot in every test.
//   async function deployedSwapToken() {


//     // Contracts are deployed using the first signer/account by default
//     const [owner, otherAccount] = await ethers.getSigners();

//     const TokenA = await ethers.getContractFactory("TokenA")
//     const tokenA = await TokenA.deploy(100000)

//     const TokenB = await ethers.getContractFactory("TokenB")
//     const tokenB = await TokenB.deploy(100000)

//     const SwapToken = await ethers.getContractFactory("TokenSwap");
//     const swapToken = await SwapToken.deploy(tokenA.target, tokenB.target, 10);

//     return { swapToken, tokenB, tokenA, owner, otherAccount };
//   }
 
//   describe("SwapTokenAtoB", function() {
//     it("check if the amount to be swapped is greaterThan 0", async function () {

//       const { swapToken, tokenB, tokenA, owner, otherAccount } = await loadFixture(deployedSwapToken);

//       await expect(swapToken.swapTokenAtoB(0)).to.be.revertedWith("Can't exchange zero amount")

//     }) 

//     it("check if the balance of owner is greater than the amount to be swapped", async function () {

//       const { swapToken, tokenB, tokenA, owner, otherAccount } = await loadFixture(deployedSwapToken);

//       await tokenA.transfer(otherAccount, 25) 

//       await expect(swapToken.connect(otherAccount).swapTokenAtoB(30)).to.be.revertedWith("Insufficient Balance")
//     }) 

//     it ("check if the balance of contract is sufficient", async function (){

//       const { swapToken, tokenB, tokenA, owner, otherAccount } = await loadFixture(deployedSwapToken);

//       await tokenA.transfer(otherAccount, 25) 

//       await expect(swapToken.connect(otherAccount).swapTokenAtoB(20)).to.be.revertedWith("Not enough tokenB")
//     })

//     it("check if Contract is approved and transfer to contract is successful", async function (){

//       const { swapToken, tokenB, tokenA, owner, otherAccount } = await loadFixture(deployedSwapToken);
          
//       (await tokenA.approve(swapToken.target, 2000)).wait();

//       (await tokenB.transfer(swapToken.target , 50000)).wait();

//       const contractBalanceOfTokenABeforeTx = await tokenA.balanceOf(swapToken.target);
      
//       const contractBalanceOfTokenBBeforeTx = await tokenB.balanceOf(swapToken.target);

//       (await swapToken.swapTokenAtoB(2000)).wait();

//       const contractBalanceOfTokenAAfterTx = await tokenA.balanceOf(swapToken.target);

//       const contractBalanceOfTokenBAfterTx = await tokenA.balanceOf(swapToken.target);

//       expect(contractBalanceOfTokenAAfterTx).to.greaterThan(contractBalanceOfTokenABeforeTx);

//       expect(contractBalanceOfTokenBBeforeTx).to.be.greaterThan(contractBalanceOfTokenBAfterTx);

//     })
//   })


//   describe("SwapTokenBtoA", function() {
//     it("check if the amount to be swapped is greaterThan 0", async function () {

//       const { swapToken, tokenB, tokenA, owner, otherAccount } = await loadFixture(deployedSwapToken);

//       await expect(swapToken.swapTokenBtoA(0)).to.be.revertedWith("Can't exchange zero amount")

//     })

//     it("check if the balance of owner is greater than the amount to be swapped", async function () {

//       const { swapToken, tokenB, tokenA, owner, otherAccount } = await loadFixture(deployedSwapToken);

//       await tokenB.transfer(otherAccount, 25) 

//       await expect(swapToken.connect(otherAccount).swapTokenBtoA(30)).to.be.revertedWith("Insufficient Balance")
//     }) 

//     it ("check if the balance of contract is sufficient", async function (){

//       const { swapToken, tokenB, tokenA, owner, otherAccount } = await loadFixture(deployedSwapToken);

//       await tokenB.transfer(otherAccount, 25) 

//       await expect(swapToken.connect(otherAccount).swapTokenBtoA(20)).to.be.revertedWith("Not enough tokenA")
//     })

//     it("check if Contract is approved and transfer to contract is successful", async function (){

//       const { swapToken, tokenB, tokenA, owner, otherAccount } = await loadFixture(deployedSwapToken);
          
//       (await tokenB.approve(swapToken.target, 2000)).wait();

//       (await tokenA.transfer(swapToken.target , 50000)).wait();

//       const contractBalanceOfTokenABeforeTx = await tokenA.balanceOf(swapToken.target);
      
//       const contractBalanceOfTokenBBeforeTx = await tokenB.balanceOf(swapToken.target);

//       (await swapToken.swapTokenBtoA(2000)).wait();

//       const contractBalanceOfTokenAAfterTx = await tokenA.balanceOf(swapToken.target);

//       const contractBalanceOfTokenBAfterTx = await tokenA.balanceOf(swapToken.target);

//       expect(contractBalanceOfTokenAAfterTx).to.lessThan(contractBalanceOfTokenABeforeTx);

//       expect(contractBalanceOfTokenBBeforeTx).to.be.lessThan(contractBalanceOfTokenBAfterTx);

//     })
    
//   })

//   // describe("SwapTokenAtoB", function() {
//   //   it("check if the amount to be swapped is greaterThan 0", async function () {

//   //     const { swapToken, tokenB, tokenA, owner, otherAccount } = await loadFixture(deployedSwapToken);

//   //     const newExchangeRate = await expect(swapToken.changeExchangeRate(2))
//   //   })
    
//   // })
// });