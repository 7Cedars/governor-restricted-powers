// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";

contract GovernorDividedPowers is AccessManager {
  uint64 public constant COUNCILLOR = 1; 
  uint64 public constant JUDGE = 2; 

  constructor(address _initialAdmin) AccessManager(_initialAdmin) {
  } 

}