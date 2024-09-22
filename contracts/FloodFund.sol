// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FloodFund {
    // replace the addresses from your REMIX IDE | here public can also be used
    address payable private fundraiserSylhet = payable(0xDf524B65E3C5D729Fef55697d583D5e7e6Dd26b3);
    address payable private fundraiserCtgNorth = payable(0x87E818Db71E6dB793c005336BC4bE071710bbD90);
    address payable private fundraiserCtgSouth = payable(0x831C55A49c4fA7fbdc6017c0aEAA65862f5a0E38);

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

    mapping ( address => Donor ) donorList;

    // if false, the function will revert and the message in string mentioned will be thrown | if true the function continues to execute 
    modifier exceptFundreiser() {
        require(
            msg.sender != fundraiserSylhet &&
            msg.sender != fundraiserCtgNorth &&
            msg.sender != fundraiserCtgSouth,
            "Your account is a fundraiser account. Please use a non-fundreiser account."
        );
        _;
    }

    // registering the donor | the the beginning of the function call the exceptFundreiser will be executed to check its condition
     function registerDonor(string memory _name, string memory _mobileNumber) public exceptFundreiser {
        require(bytes(_name).length != 0, "Please provide name.");
        require(bytes(_mobileNumber).length != 0, "Please provide mobile number.");
        donorList[msg.sender] = Donor(_name, _mobileNumber);
    }


    function donate(string memory _fundraiserZone, string memory _mobileNumber) public payable {
        require(bytes(_mobileNumber).length != 0, "Please provide the mobile number");
        require(msg.value > 0, "Donation must be greater than 0");
        require(keccak256(abi.encodePacked(donorList[msg.sender].mobileNumber)) == keccak256(abi.encodePacked(_mobileNumber)), "Mobile Number not matched or not registered.");

        address payable destination;
        
        if (keccak256(abi.encodePacked(_fundraiserZone)) == keccak256(abi.encodePacked("sylhet"))) {
            destination = fundraiserSylhet;
        } else if (keccak256(abi.encodePacked(_fundraiserZone)) == keccak256(abi.encodePacked("chittagong-south"))) {
            destination = fundraiserCtgSouth;
        } else if (keccak256(abi.encodePacked(_fundraiserZone)) == keccak256(abi.encodePacked("chittagong-north"))) {
            destination = fundraiserCtgNorth;
        } else {
            revert("Unavailable zone");
        }

        destination.transfer(msg.value);
        
    }

    // getting all of the individual and total balance  
    function getBalance() public view returns (uint256, uint256, uint256, uint256) {
        uint256 sylhetBalance = fundraiserSylhet.balance;
        uint256 ctgNorthBalance = fundraiserCtgNorth.balance;
        uint256 ctgSouthBalance = fundraiserCtgSouth.balance;
        uint256 totalBalance = sylhetBalance + ctgNorthBalance + ctgSouthBalance;

        return (sylhetBalance, ctgNorthBalance, ctgSouthBalance, totalBalance);
    }

    // getting donor info
    function getDonorInfoByAddress(address _donorAddress) public view returns (string memory, string memory) {
        require(bytes(donorList[_donorAddress].name).length != 0 || bytes(donorList[_donorAddress].mobileNumber).length != 0, "Address not registered" );
        //  the above require here is optional and it is to check if the address is registered or not. but it is, optional 
        return (donorList[_donorAddress].name, donorList[_donorAddress].mobileNumber);
    }

}

