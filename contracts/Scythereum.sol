pragma solidity ^0.4.16;

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract TokenERC20 {
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function TokenERC20(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` in behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        assert(totalSupply >= _value);
        totalSupply -= _value;                      // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        assert(totalSupply >= _value);
        totalSupply -= _value;                              // Update totalSupply
        Burn(_from, _value);
        return true;
    }
}

/******************************************/
/*       ADVANCED TOKEN STARTS HERE       */
/******************************************/

contract Scythereum is owned, TokenERC20 {

    bool public tokenActive = true;
    address public supersedingToken;

    mapping (address => bool) public frozenAccount;

    uint256 public newMemberAward;
    uint256 public projectFundingMinimum;
    uint256 public inactivityTimeLimit = 30 days;

    /* events are placed above their associated function */

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function Scythereum(
        string tokenName,
        string tokenSymbol,
        uint256 _newMemberAward,
        uint256 _projectFundingMinimum
    ) TokenERC20(newMemberAward*10**uint256(decimals), tokenName, tokenSymbol) public { 
        newMemberAward = _newMemberAward*10**uint256(decimals);
        projectFundingMinimum = _projectFundingMinimum*10**uint256(decimals);
    }

    event NewMemberAward(uint256 newAward);
    function changeMemberAward(uint256 _newAwardMajorUnits) onlyOwner public {
        require(_newAwardMajorUnits < 1e6);
        newMemberAward = _newAwardMajorUnits*10**uint256(decimals);
        NewMemberAward(_newAwardMajorUnits);
    }

    event NewFundingMinimum(uint256 newMinimum);
    function changeFundingMinimum(uint256 _newMinimumMajorUnits) onlyOwner public {
        require(_newMinimumMajorUnits < 1e9);
        projectFundingMinimum = _newMinimumMajorUnits*10**uint256(decimals);
        NewFundingMinimum(_newMinimumMajorUnits);
    }
    event NewInactivityTimeLimit(uint256 newTimeLimit);
    function changeInactivityTimeLimit(uint256 _newTimeLimit) onlyOwner public {
        require(_newTimeLimit < 180 days && _newTimeLimit > 7 days);
        inactivityTimeLimit = _newTimeLimit;
        NewInactivityTimeLimit(_newTimeLimit);
    }

    event TokenDisabled(address newTokenAddress);
    function disableToken(address _newToken) onlyOwner public {
        tokenActive = false;
        supersedingToken = _newToken;
        TokenDisabled(_newToken);
    }

    event TokenEnabled();
    function enableToken() onlyOwner public {
        tokenActive = true;
        supersedingToken = 0x0;
        TokenEnabled();
    }

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        require(tokenActive); 								// This token contract still active
        require(_to != 0x0);                                // Prevent transfer to 0x0 address. Use burn() instead
        require(balanceOf[_from] >= _value);                // Check if the sender has enough
        require(balanceOf[_to] + _value > balanceOf[_to]);  // Check for overflows
        require(!frozenAccount[_from]);                     // Check if sender is frozen
        require(!frozenAccount[_to]);                       // Check if recipient is frozen
        require(projectStatus[_from] == ProjectStatus.Unknown || // must not be a project, or if sender is a project ...
                projectStatus[_from] == ProjectStatus.Completed && totalInvestedBy[_from] >= totalProjectFunding[_from]/2); // project must be complete && have reinvested 1/2 their tokens
        // don't prohibit transfers to projects.  This is how we invest tokens.
        balanceOf[_from] -= _value;                         // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient
        Transfer(_from, _to, _value);
    }

    enum ProjectStatus { Unknown, Active, Completed, Deactivated }
    mapping (address => ProjectStatus) public projectStatus;

    mapping (address => bool) public authenticatedMember;
    mapping (address => uint256) public lastInvestment;

    struct InvestmentRecords {
        uint256 amountInvested;
        uint256 totalEarlierInvested;
        uint256 rewardsReceived;
    }

    // indexed by member then by project 
    mapping (address => mapping (address => InvestmentRecords)) public memberInvestmentRecords; // track member investments and rewards

    // indexed by member 
    mapping (address => uint256) public totalInvestedBy; // total number of tokens the member or project has invested in projects

    //indexed by project
    mapping (address => uint256) public totalProjectFunding; // the current total tokens invested in a project

    uint256 public totalActiveGiven; // total amount invested over all time. TODO

    event NewProjectAdded(address indexed projectAddress);
    function addProject(address _project) onlyOwner public {
        require(!authenticatedMember[_project]); // not a member
        projectStatus[_project] = ProjectStatus.Active;
        NewProjectAdded(_project);
    }

    event NewMemberAdded(address indexed newMemberAddress);
    function addMember(address _member) onlyOwner public {
        require(projectStatus[_member] == ProjectStatus.Unknown); // not a project
        require(!authenticatedMember[_member]); // not already a member
        authenticatedMember[_member] = true;
        NewMemberAdded(_member);
        mintToken(_member, newMemberAward);
    }
    function addMembers(address[] _members) onlyOwner public {
        for (uint i=0; i<_members.length; i++) {
            require(projectStatus[_members[i]] == ProjectStatus.Unknown); // not a project
            require(!authenticatedMember[_members[i]]); // not already a member
            authenticatedMember[_members[i]] = true;
            NewMemberAdded(_members[i]);
            mintToken(_members[i], newMemberAward);
        }
    }

    event NewInvestment(address indexed project, uint256 amount);
    function investInProject(address _project, uint256 _amount) public {
        require(tokenActive); 								// This token contract still active
        require(!frozenAccount[msg.sender]);
        require(projectStatus[_project] == ProjectStatus.Active);
        require(authenticatedMember[msg.sender] || projectStatus[msg.sender] == ProjectStatus.Completed); // completed projects must invest before they can sell off raised tokens
        //imposeInactivityPenalty(msg.sender); // TODO: inactivity penalty currently has issues.  Candidate for removal.
        require(now - lastInvestment[msg.sender] < inactivityTimeLimit); // must call payReactivationFee() if inactive for too long

        require(_amount <= balanceOf[msg.sender]); // can't invest more than you have! (Also checked in the _transfer() function)
        require(_amount >= balanceOf[msg.sender]/33); // minimum you can give to a project is 3.3% of your balance and 5% of some flat minimum
        require(_amount >= newMemberAward/20); // donation must be above the flat minimum

        uint256 totalAmount = _amount + memberInvestmentRecords[msg.sender][_project].amountInvested; // current + previous investments in project
        require(totalAmount <= projectFundingMinimum/3); // investment can only comprise up to 1/3 the total funding
        if (projectStatus[msg.sender] == ProjectStatus.Completed) {
            require(totalAmount <= totalProjectFunding[msg.sender]/8); // projects have to spread out their new tokens over at least 8/2=4 projects
            require(_amount >= totalProjectFunding[msg.sender]/25); // projects have a stricter minimum to avoid "only helping their friends"
        }

        memberInvestmentRecords[msg.sender][_project].amountInvested += _amount;
        memberInvestmentRecords[msg.sender][_project].totalEarlierInvested = totalProjectFunding[_project]; // Should warn member of consequences if they re-invest in a project at a later date.
        _transfer(msg.sender,_project,_amount);

        totalProjectFunding[_project] += _amount;
        totalInvestedBy[msg.sender] += _amount;
        totalActiveGiven += _amount;

        lastInvestment[msg.sender] = now;

        NewInvestment(_project, _amount);
    }

    // Successfull projects must have raised the funding minimum, as well as completed the first milestone
    event SuccessfullProjectFunding(address indexed project, uint256 totalRaised);
    function closeOutFunding(address _project) onlyOwner public {
        require(projectStatus[_project] == ProjectStatus.Active);
        require(totalProjectFunding[_project] >= projectFundingMinimum);
        projectStatus[_project] = ProjectStatus.Completed;
        lastInvestment[_project] = now; // prepare for project to invest some of the received tokens
        SuccessfullProjectFunding(_project, totalProjectFunding[_project]);
    }

    // If a project becomes completed, return invested tokens + a bonus
    event MemberClaimedReward(address indexed member, address indexed project, uint256 initialInvestment, uint256 reward);
    function claimRewards(address _project) public {
        require(projectStatus[_project] == ProjectStatus.Completed);
        require(memberInvestmentRecords[msg.sender][_project].rewardsReceived==0);
        require(!frozenAccount[msg.sender]);
        uint256 newTokens = bonusTokensPlusOriginal(totalProjectFunding[_project], memberInvestmentRecords[msg.sender][_project].totalEarlierInvested, memberInvestmentRecords[msg.sender][_project].amountInvested);
        memberInvestmentRecords[msg.sender][_project].rewardsReceived = newTokens;
        MemberClaimedReward(msg.sender, _project, memberInvestmentRecords[msg.sender][_project].amountInvested, newTokens);
        mintToken(msg.sender, newTokens); // has require(tokenActive) 
    }

    // if a project goes AWOL or violates rules, let people get their investment back
    event ProjectDeactivated(address indexed project, string reason);
    function deactivateProject(address _project, string _reason) onlyOwner public {
        require(projectStatus[_project] == ProjectStatus.Active || projectStatus[_project] == ProjectStatus.Completed);
        projectStatus[_project] = ProjectStatus.Deactivated;
        ProjectDeactivated(_project, _reason);
    }

    // Undo a project deactivation into the active state (only for emergency use)
    event ProjectReactivated(address indexed project, string reason);
    function reactivateProject(address _project, string _reason) onlyOwner public {
        require(projectStatus[_project] == ProjectStatus.Deactivated);
        projectStatus[_project] = ProjectStatus.Active;
        ProjectReactivated(_project, _reason);
    }

    // Undo a project deactivation into the completed state (only for emergency use)
    event ProjectRecompleted(address indexed project, string reason);
    function recompleteProject(address _project, string _reason) onlyOwner public {
        require(projectStatus[_project] == ProjectStatus.Deactivated);
        projectStatus[_project] = ProjectStatus.Completed;
        ProjectRecompleted(_project, _reason);
    }

    event MemberReclaimedFromDeactiveProject(address indexed member, address indexed project, uint256 initialInvestment);
    function reclaimDeactivatedProjectFunds(address _project) public {
        require(projectStatus[_project] == ProjectStatus.Deactivated);
        require(!frozenAccount[msg.sender]);
        require(memberInvestmentRecords[msg.sender][_project].rewardsReceived==0);
        uint256 reclaimedAmount = memberInvestmentRecords[msg.sender][_project].amountInvested;
        memberInvestmentRecords[msg.sender][_project].rewardsReceived = reclaimedAmount;
        memberInvestmentRecords[msg.sender][_project].amountInvested = 0; // in case a project is reactivated, zero out their investment history
        MemberReclaimedFromDeactiveProject(msg.sender, _project, reclaimedAmount);
        _transfer(_project,msg.sender,reclaimedAmount); // consider consequences of require(tokenActive) in _transfer()
    }

    // the bonus amount exponentially decreases, until reaching zero for the last tiny bit
    function bonusTokensPlusOriginal(uint256 _totalDonations, uint256 _previousDonations, uint256 _newDonation) public pure returns (uint256 tokens) {
        uint256 previousFractionE6 = _previousDonations * 1e6 / _totalDonations;
        uint256 newFractionE6 = (_previousDonations + _newDonation) * 1e6 / _totalDonations;
        // The prefactor is 10^6 * 1/(1-e^-1) and ensures that the new "wei" is 0
        tokens = 1.581976e6 * _totalDonations * (approxNegativeExpE6(previousFractionE6) - approxNegativeExpE6(newFractionE6)) / 1e12;
        // The prefactor is e^1) and ensures that the last invested "wei" is simply returned without appreciation. Successful projects generate (e^1-1) wei.
        tokens = 2718281 *  _totalDonations * (approxNegativeExpE6(previousFractionE6) - approxNegativeExpE6(newFractionE6)) / 1e12;
    }

    function approxNegativeExpE6(uint256 xe6) internal pure returns (uint256) {
        require(xe6<=1e6); // x can go from 0 to 1
        // return approximation of 10^6 * exp(-x), given x*10^6
        // piecewise taylor series approximation accurate at about >99% 
        // taylor series at 0 (technically we should expand the taylor series at some positive x_0 even for this first piecewise component)
        if (xe6 < 20 * 10**4)
            return (10**12 - 10**6*xe6 + xe6**2 / 2)/10**6;
        // Taylor series around x_0=0.57
        // exp(-x_0) + (-1)exp(-x_0)(x-x_0) + exp(-x_0)(x-x_0)^2 + (-1)exp(-x_0)(x-x_0)^3
        // e^(-0.57) = 0.565525 (the similarity is a coincidence)
        // Note: solidity can't exponentiate a negative number if the operands are uint. Example: (x-x_0)**2 throws if x<x_0
        if (xe6 < 57e4)
            return (565525 * (10**18 - 10**12 * (xe6 - 57*10**4) + 10**6 * (57*10**4 - xe6)**2 / 2 + (57*10**4 - xe6)**3 / 6)) / 10**18;

        return (565525 * (10**18 - 10**12 * (xe6 - 57*10**4) + 10**6 * (xe6 - 57*10**4)**2 / 2 - (xe6 - 57*10**4)**3 / 6)) / 10**18;
    }

    event NewTokensMinted(address indexed recipient, uint256 amount);
    /// @notice Create `_mintedAmount` tokens and send it to `_recipient`
    /// @param _recipient Address to receive the tokens
    /// @param _mintedAmount the amount of tokens it will receive
    function mintToken(address _recipient, uint256 _mintedAmount) internal { // make internal or onlyOwner
        require(tokenActive);
        require(!frozenAccount[_recipient]);
        balanceOf[_recipient] += _mintedAmount;
        totalSupply += _mintedAmount;
        lastInvestment[_recipient] = now; // set to start inactivity timer
        NewTokensMinted(_recipient, _mintedAmount);
        Transfer(0, this, _mintedAmount);
        Transfer(this, _recipient, _mintedAmount);
    }

    // Ensure token holders are actively investing in projects
    // The current problem is that members can transfer some tokens to a nonmember account to "protect" them. 
    // TODO: My current thinking is that token inflation *already* incentivizes active participation, and this may be removed.
    //event InactivityPenalty(address indexed member, uint256 inactiveDays, uint256 initialBalance, uint256 penalty);
    //function imposeInactivityPenalty(address _member) internal {
    //    uint256 elapsed = now - lastTokenAction[_member];
    //    if (elapsed > 25 weeks) elapsed = 25 weeks;
    //    if (elapsed < 30 days) elapsed = 0;
    //    uint256 tokenDecrease = elapsed * balanceOf[_member] / (25 weeks);
    //    if (tokenDecrease > 0)
    //        InactivityPenalty(_member, elapsed/(1 days), balanceOf[_member], tokenDecrease);
    //    balanceOf[_member] -= tokenDecrease;
    //    totalSupply -= tokenDecrease;
    //    lastTokenAction[_member] = now;
    //}

    function payReactivationFee() public {
        require(authenticatedMember[msg.sender] || projectStatus[msg.sender] == ProjectStatus.Completed);
        require(balanceOf[msg.sender] >= newMemberAward/10);
        require(now - lastInvestment[msg.sender] >= inactivityTimeLimit); 
        burn(newMemberAward/10);
        lastInvestment[msg.sender] = now;
    }

    event FrozenFunds(address indexed target, bool frozen);
    /// @notice `_freeze? Prevent | Allow` `_target` from sending & receiving tokens
    /// @param _target Address to be frozen
    /// @param _freeze either to freeze it or not
    function freezeAccount(address _target, bool _freeze) onlyOwner public {
        require(authenticatedMember[_target]);
        frozenAccount[_target] = _freeze;
        FrozenFunds(_target, _freeze);
    }

	// A vulernability of the approve method when resetting an allowance in the ERC20 standard was identified by
  	// Mikhail Vladimirov and Dmitry Khovratovich here:
  	// https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM
  	// It's better to use this method to reset an allowance as it is not susceptible to double-withdraws by the approvee.
  	/// @param _spender The address to approve
  	/// @param _currentAllowance The previous allowance approved, which can be retrieved with allowance(msg.sender, _spender)
  	/// @param _newAllowance The new allowance to approve, this will replace the _currentAllowance
  	/// @return bool Whether the approval was a success (see ERC20's `approve`)
  	function secureApprove(address _spender, uint256 _currentAllowance, uint256 _newAllowance) public returns(bool) {
		if (allowance[msg.sender][_spender] != _currentAllowance) {
			return false;
    	}
		return approve(_spender, _newAllowance);
	}

}

