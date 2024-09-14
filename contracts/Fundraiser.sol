// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


contract Fundraiser {

    enum Region {Sylhet, ChittagongSouth, ChittagongNorth}

    struct Donor {
        string name;
        string mobileNumber;
        bool isRegistered;
    }

    mapping(Region => address payable) public fundraisers;
    mapping(Region => uint256) public totalDonations;
    mapping(address => Donor) public donors;

    // predefined fundraiser account
    constructor() {
        fundraisers[Region.Sylhet] = payable(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
        fundraisers[Region.ChittagongSouth] = payable(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
        fundraisers[Region.ChittagongNorth] = payable(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db);
    }

    // donor registration
    function registerDonor(string memory name, string memory mobileNumber) external {
    require(
        msg.sender != fundraisers[Region.Sylhet] &&
        msg.sender != fundraisers[Region.ChittagongSouth] &&
        msg.sender != fundraisers[Region.ChittagongNorth],
        "Fundraiser accounts cannot register as donors"
    );

    require(bytes(name).length > 0, "Name required");
    require(bytes(mobileNumber).length > 0, "Mobile number required");
    require(!donors[msg.sender].isRegistered, "Already registered");

    donors[msg.sender] = Donor(name, mobileNumber, true);
}

    // donate
    function donate(Region region, string memory mobileNumber) external payable {
        require(msg.value > 0, "Donation amount cannot be 0");
        require(donors[msg.sender].isRegistered, "Not registered");
        require(
            keccak256(abi.encodePacked(donors[msg.sender].mobileNumber)) == keccak256(abi.encodePacked(mobileNumber)),
            "Mobile number does not match"
        );
        
        fundraisers[region].transfer(msg.value);
        totalDonations[region] += msg.value;

    }

    function getTotalDonation() external view returns (uint256) {
        return totalDonations[Region.Sylhet] + totalDonations[Region.ChittagongSouth] + totalDonations[Region.ChittagongNorth];
    }

    function getDonationAmount(Region region) external view returns (uint256) {
        return totalDonations[region];
    }

    function getDonorInfo(address donorAddress) external view returns (string memory name, string memory mobileNumber) {
        require(donors[donorAddress].isRegistered, "Not registered");
        Donor memory donor = donors[donorAddress];
        return (donor.name, donor.mobileNumber);
    }
}