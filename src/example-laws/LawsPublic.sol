// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {GovernedIdentity} from "../../src/example-governance-system/GovernedIdentity.sol";
import {LawTemplate} from "../../src/example-laws/LawTemplate.sol";

/**
 * @title Example Public Laws, to be used in combination with the GovernorDividedPowers extension of Governor.sol.
 *
 * @author Seven Cedars
 *
 * @notice Public laws are 'normal' laws that manage functioning of broader protocol.
 *
 * £todo: check gas usage of string descriptions. How bad is it?
 */
contract LawsPublic is LawTemplate {
    /* Errors */

    /* State variables. */

    /* FUNCTIONS */
    /* constructor */
    constructor(address payable governedIdentity) LawTemplate(governedIdentity) {}

    // role restriction: CITIZEN
    // function: mint 1 token - should not be possible to transfer.

    // role restriction: COUNCILLOR
    // function: citizenIsNotUnique => cancel citizenship + burn token.

    // role restriction: COUNCILLOR
    // function: citizenIsNotHuman => cancel citizenship + burn token.

    // function: internal law to revoke citizenship + burn token
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
