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

    function testBurning() public {
        vm.startPrank(owner);
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
}
