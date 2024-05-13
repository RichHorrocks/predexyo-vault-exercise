// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {WETH} from "./mocks/WETH.sol";
import {MockERC20} from "./mocks/MockERC20.sol";

import {Vault} from "../src/Vault.sol";
import {Errors} from "../src/errors/Errors.sol";

contract VaultWrapTest is Test {
    Vault private vault;
    WETH private weth;
    address private alice;

    function setUp() public {
        weth = new WETH();
        vault = new Vault(address(weth));
        alice = vm.addr(0x1);
        vm.deal(alice, 1000);
    }

    function test_DepositETH() public {
        vm.startPrank(alice);
        vault.depositETH{value: 1000}();
        vm.stopPrank();

        assertEq(vault.balances(address(alice)), 1000);
    }

    function test_WithdrawETH() public {
        vm.startPrank(alice);
        vault.depositETH{value: 1000}();
        vault.withdrawETH(500);
        vm.stopPrank();

        assertEq(vault.balances(address(alice)), 500);
    }

    function testFail_WithdrawETH_InsufficientBalance() public {
        vm.startPrank(alice);
        vault.depositETH{value: 10}();
        vm.expectRevert(Errors.InsufficientETHBalance.selector);
        vault.withdrawETH(100);
        vm.stopPrank();
    }

    function test_WrapETH() public {
        vm.startPrank(alice);
        vault.depositETH{value: 1000}();
        vault.wrapETH(1000);
        vm.stopPrank();

        assertEq(vault.balances(address(alice)), 0);
        assertEq(vault.wrappedBalances(address(alice)), 1000);
        assertEq(weth.balanceOf(address(vault)), 1000);
    }

    function testFail_WrapETH_InsufficientBalance() public {
        vm.startPrank(alice);
        vault.depositETH{value: 10}();
        vm.expectRevert(Errors.InsufficientETHBalance.selector);
        vault.wrapETH(100);
        vm.stopPrank();
    }

    function test_UnwrapETH() public {
        vm.startPrank(alice);
        vault.depositETH{value: 1000}();
        vault.wrapETH(1000);
        vault.unwrapETH(500);
        vm.stopPrank();

        assertEq(vault.balances(address(alice)), 500);
        assertEq(vault.wrappedBalances(address(alice)), 500);
        assertEq(weth.balanceOf(address(vault)), 500);
    }

    function testFail_UnwrapETH_InsufficientWrappedBalance() public {
        vm.startPrank(alice);
        vault.depositETH{value: 1000}();
        vault.wrapETH(1000);
        vm.expectRevert(Errors.InsufficientWrappedBalance.selector);
        vault.unwrapETH(1001);
        vm.stopPrank();
    }
}
