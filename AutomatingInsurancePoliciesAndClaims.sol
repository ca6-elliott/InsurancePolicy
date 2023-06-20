// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Insurance is Ownable {

    struct Policy {
        uint256 policyId;
        uint256 premium;
        uint256 coverageAmount;
        uint256 expirationDate;
        address policyHolder;
        bool isActive;
    }
    
    struct Claim {
        uint256 policyId;
        uint256 claimAmount;
        string reason;
        bool isApproved;
    }
    
    mapping(uint256 => Policy) public policies;
    mapping(uint256 => Claim) public claims;
    uint256 public policyCounter;
    uint256 public claimCounter;
    
    event PolicyCreated(uint256 indexed policyId, uint256 premium, uint256 coverageAmount, uint256 expirationDate, address indexed policyHolder);
    event PolicyCancelled(uint256 indexed policyId);
    event ClaimSubmitted(uint256 indexed policyId, uint256 claimAmount, string reason);
    event ClaimApproved(uint256 indexed claimId);
    event ClaimDenied(uint256 indexed claimId);
    
    function createPolicy(uint256 _premium, uint256 _coverageAmount, uint256 _expirationDate) public payable {
        require(msg.value == _premium, "Premium does not match payment amount");
        policies[policyCounter] = Policy(policyCounter, _premium, _coverageAmount, _expirationDate, msg.sender, true);
        policyCounter++;
        emit PolicyCreated(policyCounter - 1, _premium, _coverageAmount, _expirationDate, msg.sender);
    }
    
    function cancelPolicy(uint256 _policyId) public onlyOwner {
        require(policies[_policyId].isActive, "Policy is not active");
        policies[_policyId].isActive = false;
        payable(policies[_policyId].policyHolder).transfer(policies[_policyId].premium);
        emit PolicyCancelled(_policyId);
    }
    
    function submitClaim(uint256 _policyId, uint256 _claimAmount, string memory _reason) public {
        require(policies[_policyId].isActive, "Policy is not active");
        require(policies[_policyId].policyHolder == msg.sender, "Only the policy holder can submit a claim");
        require(_claimAmount <= policies[_policyId].coverageAmount, "Claim amount exceeds coverage amount");
        claims[claimCounter] = Claim(_policyId, _claimAmount, _reason, false);
        claimCounter++;
        emit ClaimSubmitted(_policyId, _claimAmount, _reason);
    }
    
    function approveClaim(uint256 _claimId) public onlyOwner {
        require(!claims[_claimId].isApproved, "Claim has already been approved or denied");
        claims[_claimId].isApproved = true;
        payable(policies[claims[_claimId].policyId].policyHolder).transfer(claims[_claimId].claimAmount);
        emit ClaimApproved(_claimId);
    }
    
    function denyClaim(uint256 _claimId) public onlyOwner {
        require(!claims[_claimId].isApproved, "Claim has already been approved or denied");
        claims[_claimId].isApproved = true;
        emit ClaimDenied(_claimId);
    }
}
