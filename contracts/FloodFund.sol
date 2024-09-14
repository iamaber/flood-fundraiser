// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FloodFund {
    address payable public fundraiserSylhet;
    address payable public fundraiserCtgNorth;
    address payable public fundraiserCtgSouth;
    address public owner;

    struct Donor {
        string name;
        string mobileNumber;
    }

    struct Balance{
        uint256 sylhet;
        uint256 ctgNorth;
        uint256 ctgSouth;
        uint256 total;
    }

    mapping (address => Donor) donorList;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function setFundraisers(address payable _sylhet, address payable _ctgNorth, address payable _ctgSouth) external onlyOwner {
        fundraiserSylhet = _sylhet;
        fundraiserCtgNorth = _ctgNorth;
        fundraiserCtgSouth = _ctgSouth;
    }

    modifier exceptFundreiser() {
        require(
            msg.sender != fundraiserSylhet &&
            msg.sender != fundraiserCtgNorth &&
            msg.sender != fundraiserCtgSouth,
            "Your account is a fundraiser account. Please use a non-fundraiser account."
        );
        _;
    }

    function registerDonor(string memory _name, string memory _mobileNumber) public exceptFundreiser {
        require(bytes(_name).length != 0, "Please provide name.");
        require(bytes(_mobileNumber).length != 0, "Please provide mobile number.");
        donorList[msg.sender] = Donor(_name, _mobileNumber);
    }

    function donate(string memory _fundraiserZone, string memory _mobileNumber) public payable {
        require(bytes(_mobileNumber).length != 0, "Please provide the mobile number" );
        require(keccak256(abi.encodePacked(donorList[msg.sender].mobileNumber)) == keccak256(abi.encodePacked(_mobileNumber)), "Mobile Number not matched or not registered.");

        if (keccak256(abi.encodePacked(_fundraiserZone)) == keccak256(abi.encodePacked("sylhet"))) {
            fundraiserSylhet.transfer(msg.value);
        } 
        else if (keccak256(abi.encodePacked(_fundraiserZone)) == keccak256(abi.encodePacked("chittagong-south"))) {
            fundraiserCtgNorth.transfer(msg.value);
        } 
        else if (keccak256(abi.encodePacked(_fundraiserZone)) == keccak256(abi.encodePacked("chittagong-north"))) {
            fundraiserCtgSouth.transfer(msg.value);
        } 
        else{
            revert("Unavailable zone");
        }
    }

    function getBalance() public view returns (Balance memory) {
        uint256 total = address(fundraiserSylhet).balance + address(fundraiserCtgNorth).balance + address(fundraiserCtgSouth).balance;
        return Balance(address(fundraiserSylhet).balance, address(fundraiserCtgNorth).balance, address(fundraiserCtgSouth).balance, total);
    }

    function getDonorInfoByAddress(address _donorAddress) public view returns (string memory, string memory) {
        require(bytes(donorList[_donorAddress].name).length != 0 || bytes(donorList[_donorAddress].mobileNumber).length != 0, "Address not registered" );
        return (donorList[_donorAddress].name, donorList[_donorAddress].mobileNumber);
    }
}