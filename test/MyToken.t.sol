// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken private token;
    address private owner = address(0x1);
    address private user = address(0x2);

    function setUp() public {
        vm.startPrank(owner);
        token = new MyToken(owner, "MyToken", "MTK", 1000);
        vm.stopPrank();
    }

    function testInitialSupply() public view {
        assertEq(token.balanceOf(owner), 1000 * (10 ** token.decimals()));
    }

    function testMinting() public {
        vm.startPrank(owner);
        token.mint(owner, 500 * (10 ** token.decimals()));
        assertEq(token.balanceOf(owner), 1500 * (10 ** token.decimals()));
        vm.stopPrank();
    }

    // everyone can burn, not only for Onwer

    function testBurning() public {
        vm.startPrank(owner);
        token.transfer(user, 100 * (10 ** token.decimals()));
        vm.stopPrank();
        vm.startPrank(user);
        token.burn(100 * (10 ** token.decimals()));
        assertEq(token.balanceOf(owner), 900 * (10 ** token.decimals()));
        vm.stopPrank();
    }

    function testOnlyOwnerCanMint() public {
        console.log("Caller: %s, Owner: %s", user, token.owner());
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                address(user)
            )
        );
        vm.startPrank(user);
        token.mint(user, 500);
        vm.stopPrank();
    }

    function testPauseState() public {
        vm.startPrank(owner);
        // Check initial state (should not be paused)
        assertEq(token.paused(), false);

        // Pause the token
        token.pause();

        // Verify the pause state
        assertEq(token.paused(), true);

        // Try transferring tokens (should fail when paused)
        vm.expectRevert();
        token.transfer(address(user), 100);

        // Unpause the token
        token.unpause();

        // Verify the unpause state
        assertEq(token.paused(), false);
        assertEq(token.transfer(address(user), 100), true);

        // Transfer tokens (should succeed after unpausing)
        token.transfer(address(user), 100);
        assertEq(token.balanceOf(address(user)), 200);
        vm.stopPrank();
    }

    function testOnlyOwnerCanPause() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                address(user)
            )
        );
        vm.startPrank(user);
        token.pause();
        vm.stopPrank();
    }
}
