// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Service Agreement Contract
/// @dev This contract facilitates service agreements between Company A and Company B with milestone-based payments.
contract ServiceAgreement {
    /// @notice Address of Company A
    address public companyA;

    /// @notice Address of Company B
    address public companyB;

    /// @notice Number of milestones in the contract
    uint public milestoneCount;

    /// @notice Status of the contract, active or not
    bool public contractActive;

    /// @notice Mapping of milestone index to payment amount
    mapping(uint => uint) public milestonePayments;

    /// @notice Mapping of milestone index to deadline timestamp
    mapping(uint => uint) public milestoneDeadlines;

    /// @notice Mapping to track if a milestone is submitted
    mapping(uint => bool) public milestonesSubmitted;

    /// @notice Mapping to track if a milestone is approved
    mapping(uint => bool) public milestonesApproved;

    /// @notice Event emitted when a milestone is submitted
    /// @param milestone The milestone number that was submitted
    event MilestoneSubmitted(uint milestone);

    /// @notice Event emitted when a milestone is approved
    /// @param milestone The milestone number that was approved
    event MilestoneApproved(uint milestone);

    /// @notice Event emitted when a payment is released to Company B
    /// @param to The address to which the payment is released (Company B)
    /// @param amount The amount of payment released
    event PaymentReleased(address to, uint amount);

    /// @notice Event emitted when funds are deposited into the contract
    /// @param from The address from which the funds were deposited
    /// @param amount The amount of funds deposited
    event FundsDeposited(address from, uint amount);

    /// @notice Event emitted when the contract is deactivated
    event ContractDeactivated();

    /// @notice Constructor to initialize the contract
    /// @param _companyA Address of Company A
    /// @param _companyB Address of Company B
    /// @param _milestoneCount Number of milestones
    /// @param _milestonePayments Array of milestone payment amounts
    /// @param _milestoneDeadlines Array of milestone deadlines
    /// @param totalContractValue Total value of the contract
    constructor(
        address _companyA,
        address _companyB,
        uint256 _milestoneCount,
        uint256[] memory _milestonePayments,
        uint256[] memory _milestoneDeadlines,
        uint256 totalContractValue
    ) payable {
        require(_milestoneCount == _milestonePayments.length, "Milestone count and payment length mismatch");
        require(_milestoneCount == _milestoneDeadlines.length, "Milestone count and deadline length mismatch");

        uint256 sumOfPayments = 0;
        for (uint i = 0; i < _milestoneCount; i++) {
            milestonePayments[i] = _milestonePayments[i];
            milestoneDeadlines[i] = _milestoneDeadlines[i];
            sumOfPayments += _milestonePayments[i];
        }
        require(sumOfPayments == totalContractValue, "Total contract value does not match the sum of milestone payments");
        require(totalContractValue == msg.value, "Sent value does not match the total contract value");

        companyA = _companyA;
        companyB = _companyB;
        milestoneCount = _milestoneCount;
        contractActive = true;
    }

    modifier onlyCompanyA() {
        require(msg.sender == companyA, "Only Company A can call this function");
        _;
    }

    modifier onlyCompanyB() {
        require(msg.sender == companyB, "Only Company B can call this function");
        _;
    }

    /// @notice Submit a milestone by Company B
    /// @param milestone Milestone number to submit
    function submitMilestone(uint milestone) public onlyCompanyB {
        require(contractActive, "Contract is not active");
        require(milestone < milestoneCount, "Invalid milestone number");
        require(!milestonesSubmitted[milestone], "Milestone already submitted");

        milestonesSubmitted[milestone] = true;
        emit MilestoneSubmitted(milestone);
    }

    /// @notice Approve a milestone by Company A
    /// @param milestone Milestone number to approve
    function approveMilestone(uint milestone) public onlyCompanyA {
        require(contractActive, "Contract is not active");
        require(milestonesSubmitted[milestone], "Milestone not yet submitted");
        require(!milestonesApproved[milestone], "Milestone already approved");
        require(block.timestamp <= milestoneDeadlines[milestone], "Milestone approval deadline missed");

        milestonesApproved[milestone] = true;
        releasePayment(milestone);
        emit MilestoneApproved(milestone);
    }

    /// @notice Release payment for a milestone
    /// @param milestone Milestone number for which to release the payment
    function releasePayment(uint milestone) internal {
        uint paymentAmount = milestonePayments[milestone];
        require(address(this).balance >= paymentAmount, "Insufficient contract balance");

        payable(companyB).transfer(paymentAmount);
        emit PaymentReleased(companyB, paymentAmount);
    }

    /// @notice Deactivate the contract by Company A
    function deactivateContract() public onlyCompanyA {
        contractActive = false;
        emit ContractDeactivated();
    }

    /// @notice Withdraw remaining funds by Company A after contract deactivation
    function withdrawRemainingFunds() public onlyCompanyA {
        require(!contractActive, "Contract is still active");
        uint balance = address(this).balance;
        payable(companyA).transfer(balance);
    }
}
