// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.13;

import "prb-math/PRBMathUD60x18.sol";

/// @notice Surge Auction Market Maker for single sided assets
contract SAMM {
    using PRBMathUD60x18 for uint256;
    
    // Graph vvvv (does not have an equation to solve for t)
    // https://www.desmos.com/calculator/mh4drcwkqt

    // y = p*√x/t
    // y = finalPrice
    // p = floorPrice
    // x = maxima

    // t = affects the price.  If x/t = 1 then y = floorPrice as y = p√1 -> y = p*1.  
    // If t is smaller than x then price increases.  e.i. y = p√10/1 -> y = p*3.16227766017
    // If t is larger than x then price decreases.  e.i. y = p√10/20 -> y = p*0.158113883 
    
    // SurgeLength = # of blocks to decay 1 point

    // Floor price of asset
    uint256 public floorPrice; // p
    uint256 public maxima; // t

    // Both used to calculate t //
     // (timeStamp + decayLength) - block.timestamp / decayLength = t | Calculated in function to save SLOAD
    // Timestamp of last minter
    uint256 public timeStamp;
    // # of blocks to decay 1 unit
    uint256 public decayLength;
    
    constructor(uint256 _floorPrice, uint256 _maxima, uint256 _decayLength) {
        floorPrice = _floorPrice;
        maxima = _maxima;
        decayLength = _decayLength; 
    }

    function sqrt(uint256 x) internal pure returns (uint256 z) {
        assembly {
            // This segment is to get a reasonable initial estimate for the Babylonian method.
            // If the initial estimate is bad, the number of correct bits increases ~linearly
            // each iteration instead of ~quadratically.
            // The idea is to get z*z*y within a small factor of x.
            // More iterations here gets y in a tighter range. Currently, we will have
            // y in [256, 256*2^16). We ensure y>= 256 so that the relative difference
            // between y and y+1 is small. If x < 256 this is not possible, but those cases
            // are easy enough to verify exhaustively.
            z := 181 // The 'correct' value is 1, but this saves a multiply later
            let y := x
            // Note that we check y>= 2^(k + 8) but shift right by k bits each branch,
            // this is to ensure that if x >= 256, then y >= 256.
            if iszero(lt(y, 0x10000000000000000000000000000000000)) {
                y := shr(128, y)
                z := shl(64, z)
            }
            if iszero(lt(y, 0x1000000000000000000)) {
                y := shr(64, y)
                z := shl(32, z)
            }
            if iszero(lt(y, 0x10000000000)) {
                y := shr(32, y)
                z := shl(16, z)
            }
            if iszero(lt(y, 0x1000000)) {
                y := shr(16, y)
                z := shl(8, z)
            }
            // Now, z*z*y <= x < z*z*(y+1), and y <= 2^(16+8),
            // and either y >= 256, or x < 256.
            // Correctness can be checked exhaustively for x < 256, so we assume y >= 256.
            // Then z*sqrt(y) is within sqrt(257)/sqrt(256) of x, or about 20bps.

            // The estimate sqrt(x) = (181/1024) * (x+1) is off by a factor of ~2.83 both when x=1
            // and when x = 256 or 1/256. In the worst case, this needs seven Babylonian iterations.
            z := shr(18, mul(z, add(y, 65536))) // A multiply is saved from the initial z := 181

            // Run the Babylonian method seven times. This should be enough given initial estimate.
            // Possibly with a quadratic/cubic polynomial above we could get 4-6.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // See https://en.wikipedia.org/wiki/Integer_square_root#Using_only_integer_division.
            // If x+1 is a perfect square, the Babylonian method cycles between
            // floor(sqrt(x)) and ceil(sqrt(x)). This check ensures we return floor.
            // The solmate implementation assigns zRoundDown := div(x, z) first, but
            // since this case is rare, we choose to save gas on the assignment and
            // repeat division in the rare case.
            // If you don't care whether floor or ceil is returned, you can skip this.
            if lt(div(x, z), z) {
                z := div(x, z)
            }
        }
    }
  
    function setVariables(uint256 _floorPrice, uint256 _maxima, uint256 _timeStamp, uint256 _decayLength) public {
        floorPrice = _floorPrice;
        maxima = _maxima;
        timeStamp = _timeStamp;
        decayLength = _decayLength;
    }

    // allow admin/owner to set how long x-t = 0 should at for
    // & decay rate with lowest price willing to sell at
    // if (x-t) < 0, then convert to uint and add maxima to it. 
    // Need to solve for t differently to get proper decay effect
    // Variables in equation that solves for t:
    // Constant iteration and never changes: blockTimestamp
    // 
    function calcPrice() public returns (uint256) {
        uint256 _timeStamp = timeStamp;
        uint256 _decayLength = decayLength;
        uint256 _floorPrice = floorPrice;

        if ((_timeStamp + _decayLength) - block.timestamp > 1) {
        
        // I'm sorry but we gotta work through the solution bottom to top if we wanna save  
        // 48 gas
        uint256 currentPrice = 
            // solving floorPrice * result of √x/t
            _floorPrice.mul(
            // solving √x/t
                sqrt(
            // solving x/t
                    maxima.div(
            // solving for t
                        (_timeStamp + _decayLength) - block.timestamp
                    )
                )
            );
            
            return currentPrice;
        } else {
            return _floorPrice;
        }
    }

    function mint() public returns (bool) {
            // update timeStamp
            // calculate price
            timeStamp = block.timestamp;

    }
}