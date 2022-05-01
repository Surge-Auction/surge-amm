// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.13;

import {SAMM} from "../SAMM.sol";
// Test Suite
import {XConsole} from "./utils/Console.sol";
import {DSTest} from "ds-test/test.sol";
import "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";

contract SAMMTest is Test {
    using stdStorage for StdStorage;
    XConsole console = new XConsole();

    StdStorage public stdStore;

    SAMM public sAMM;

    // Constructor values
    uint256 _floorPrice;
    uint256 _maxima;
    uint256 _decayLength;

    function setUp() public {
        sAMM = new SAMM(_floorPrice, _maxima, _decayLength);
        console.log(unicode"🧪 Testing Something...");
    }   

    function testPrice() public {
        // uint256 _floorPrice
        // uint256 _maxima 
        // uint256 _timeStamp 
        // uint256 _decayLength
        // asserted values retrieved from Desmos
        // https://www.desmos.com/calculator/ty3uhgfhmc
        // We can increase the granularity by increasing the maxima
        // and possibly switch to seconds instead of using block.timestamp   
        sAMM.setVariables(0.1e18, 1000, 0, 1000);
        
        vm.warp(100);
        uint256 price1 = sAMM.calcPrice();
        assertEq(price1, 105409255);
     
        vm.warp(200);
        uint256 price2 = sAMM.calcPrice();
        assertEq(price2, 111803399);
    
        vm.warp(300);
        uint256 price3 = sAMM.calcPrice();
        assertEq(price3, 119522861);

         vm.warp(400);
        uint256 price4 = sAMM.calcPrice();
        assertEq(price4, 129099445);
     
        vm.warp(500);
        uint256 price5 = sAMM.calcPrice();
        assertEq(price5, 141421356);
    
        vm.warp(600);
        uint256 price6 = sAMM.calcPrice();
        assertEq(price6, 158113883);

         vm.warp(700);
        uint256 price7 = sAMM.calcPrice();
        assertEq(price7, 182574186);

        vm.warp(800);
        uint256 price8 = sAMM.calcPrice();
        assertEq(price8, 223606798);
 
        vm.warp(900);
        uint256 price9 = sAMM.calcPrice();
        assertEq(price9, 316227766);
    }
}
