// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.13;

import {Main} from "../Main.sol";
// Test Suite
import {XConsole} from "./utils/Console.sol";
import {DSTest} from "ds-test/test.sol";
import "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";

contract CustomLogTest is Test {
    using stdStorage for StdStorage;
    XConsole console = new XConsole();

    StdStorage public stdStore;

    Main public main;

    // Constructor values
    uint256 _floorPrice;
    uint256 _maxima;
    uint256 _decayLength;

    function setUp() public {
        main = new Main(_floorPrice, _maxima, _decayLength);
        console.log(unicode"🧪 Testing Something...");
    }   

    function testPrice() public {
        // uint256 _floorPrice
        // uint256 _maxima 
        // uint256 _timeStamp 
        // uint256 _decayLength
        // asserted values retrieved from Desmos
        main.setVariables(1e18, 10, 0, 10);
        vm.warp(1);
        uint256 price1 = main.calcPrice();
        assertEq(price1, 1054092553);
     
        vm.warp(2);
        uint256 price2 = main.calcPrice();
        assertEq(price2, 1118033988);
    
        vm.warp(3);
        uint256 price3 = main.calcPrice();
        assertEq(price3, 1195228609);
   
        vm.warp(8);
        uint256 price8 = main.calcPrice();
        assertEq(price8, 2236067977);
 
        vm.warp(9);
        uint256 price9 = main.calcPrice();
        assertEq(price9, 1000000000000000000);
 
    }
}
