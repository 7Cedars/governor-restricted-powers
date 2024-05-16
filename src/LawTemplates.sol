// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract LawTemplates is AccessControl {

  fallback() external {
    emit IncorrectSelector(msg.sender);
  }

  /* State variables */
  uint256 public justAStateVar;

  /* Events */
  event IncorrectSelector(address indexed sender); 

  function helloWorld (uint256 _var) external {
      justAStateVar = _var; 
  }


}

// Structure contract // -- from Patrick Collins.
/* version */
/* imports */
/* errors */
/* interfaces, libraries, contracts */
/* Type declarations */
/* State variables */
/* Events */
/* Modifiers */

/* FUNCTIONS: */
/* constructor */
/* receive function (if exists) */
/* fallback function (if exists) */
/* external */
/* public */
/* internal */
/* private */
/* internal & private view & pure functions */
/* external & public view & pure functions */

