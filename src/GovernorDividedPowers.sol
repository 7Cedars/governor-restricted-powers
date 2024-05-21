// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import { GovernorCountingSimple } from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";

abstract contract GovernorDividedPowers is Governor, AccessManager, GovernorCountingSimple {
  // needs to be immutable & part of constructor args when transforming this into extension. 

  error GovernorDividedPowers__ProposalContainsUnauthorizedCalls(bytes[] calldatas);
  error GovernorDividedPowers__ProposalContainsMultipleRoles(bytes[] calldatas);
  error GovernorDividedPowers__UnauthorizedVote(uint256 proposalId); 

  // additional mapping needed to keep track of role restriction of proposal. 
  mapping(uint256 proposalId => uint64) private _proposalsRole;

  // modifier to restrict who can propose and vote on proposals based on restriction of fucntion that proposal calls.  
  // notice the input. The function that get this modifier need to have these inputs. 
  // 1: function _propose
  // 2: NB function _castVote works with proposalId :D 
  // 3: function _cancel -- works with target values and calldatas. NOTE: only cancable by the proposer Does NOT need additional check. 
  // 4: function _executeOperations / execute: NOT needed. Only executes successful proposals - that already are role restricted. 
  // there might be cases where you want execution not to be restricted.  
  // queu? - redundant 
  // relay? - redundant 

  // what about 
  // 6: grantRole
  // 7: labelRole?   
  // revokeRole 
  // setRoleAdmin... 
  // etc: all functions related to admin and setting role. I have to deal with those. Should only be callable through external / governance functions 

  constructor(address _initialAdmin) AccessManager(_initialAdmin) {} 

  /**
   * Overriding the propose function with two additional checks 
   * if proposal contains calls to functions that are not callable by proposer.
   * if proposal calls functions that all have the same role restriction. Mixed role restrictions in one proposal are not allowed.  
   * 
   * Tricky think is that one proposal can call _multiple_ functions. How to deal with this? 
   * For now, the whole proposal fails. 
   *  
   */
  function _propose(
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    string memory description,
    address proposer
    ) internal override returns (uint256 proposalId) {
      // Choose not to take proposal Id from function I override. 
      // it is inefficient, but the logic of the function becomes odd as a result.
      // felt unsafe. 
      proposalId = hashProposal(targets, values, calldatas, keccak256(bytes(description)));
      // retrieving role related to first function called; 
      bytes4 functionSelector = bytes4(calldatas[0]); 
      uint64 calldatasRole = getTargetFunctionRole(targets[0], functionSelector); 

      // Check 1: in case there are more than 1 calldatas slots, check if all have the same role restriction as function 0. 
      // if not, everything reverts. 
      if (calldatas.length > 1) {
        for (uint256 i = 1; i < calldatas.length; i++) {
          functionSelector = bytes4(calldatas[i]);
          uint64 role = getTargetFunctionRole(targets[0], functionSelector); 
          if (calldatasRole != role) {
            revert GovernorDividedPowers__ProposalContainsMultipleRoles(calldatas);
          }
        }
      }

      // check 2: does proposer have the correct role?  
      (bool hasRole, ) = hasRole(calldatasRole, proposer);
      if (!hasRole) {
        revert GovernorDividedPowers__ProposalContainsUnauthorizedCalls(calldatas);
      } 

      // if checks pass, the role restriction is linked to proposalId in a mapping..   
      _proposalsRole[proposalId] = calldatasRole;
      // .. and rest of propose function is called. 
      super._propose(targets, values, calldatas, description, proposer); 

      return  proposalId; 
  } 

  // adds check 
  function _countVote(
    uint256 proposalId,
    address account,
    uint8 support,
    uint256 weight,
    bytes memory params
    ) internal virtual override (Governor, GovernorCountingSimple) {
      // we get role restriction from proposalId
      uint64 restrictedToRole =  _proposalsRole[proposalId]; 
      // and check if account has correct role assigned. 
      (bool hasRole, ) = hasRole(restrictedToRole, account);
      // if not, revert.  
      if (!hasRole) {
        revert GovernorDividedPowers__UnauthorizedVote(proposalId); 
      }
       // if it passed check, further execute _countVote function. 
      super._countVote(proposalId, account, support, weight, params); 

  }



}