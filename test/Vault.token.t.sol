// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";

import {WETH} from "./mocks/WETH.sol";
import {MockERC20} from "./mocks/MockERC20.sol";
import {Vault} from "../src/Vault.sol";
import {Errors} from "../src/errors/Errors.sol";

/// @dev Error emitted when the ERC20 allowance is insufficient.
error ERC20InsufficientAllowance();

contract VaultTokenTest is Test {
    WETH private weth;
    Vault private vault;
    MockERC20 private mockERC20;
    address private alice;

    function setUp() public {
        weth = new WETH();
        vault = new Vault(address(weth));
        mockERC20 = new MockERC20("Mock Token", "MOCK");
        alice = vm.addr(0x1);

        mockERC20.mint(alice, 1000);
    }

    function test_DepositToken() public {
        vm.startPrank(alice);
        mockERC20.approve(address(vault), 1000);
        vault.depositToken(address(mockERC20), 100);
        assertEq(vault.tokenBalances(address(alice), address(mockERC20)), 100);
        vm.stopPrank();
    }

    function testFail_DepositToken_ERC20InsufficientAllowance() public {
        vm.startPrank(alice);
        mockERC20.approve(address(vault), 10);
        vm.expectRevert(ERC20InsufficientAllowance.selector);
        vault.depositToken(address(mockERC20), 100);
        vm.stopPrank();
    }

    function test_WithdrawToken() public {
        vm.startPrank(alice);
        mockERC20.approve(address(vault), 1000);
        vault.depositToken(address(mockERC20), 100);
        vault.withdrawToken(address(mockERC20), 100);
        assertEq(vault.tokenBalances(address(alice), address(mockERC20)), 0);
        vm.stopPrank();
    }

    function testFail_WithdrawToken_InsufficientTokenBalance() public {
        vm.startPrank(alice);
        mockERC20.approve(address(vault), 1000);
        vault.depositToken(address(mockERC20), 100);
        vm.expectRevert(Errors.InsufficientTokenBalance.selector);
        vault.withdrawToken(address(mockERC20), 200);
        vm.stopPrank();
    }
}
