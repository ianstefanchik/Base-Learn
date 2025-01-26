// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract EmployeeStorage {
    uint16 private shares; // Number of shares owned by the employee
    uint32 private salary; // Monthly salary of the employee
    uint256 public idNumber; // Unique identification number of the employee
    string public name; // Name of the employee

    constructor(uint16 _shares, string memory _name, uint32 _salary, uint _idNumber) {
        shares = _shares;
        name = _name;
        salary = _salary;
        idNumber = _idNumber;
    }

    function viewShares() public view returns (uint16) {
        return shares;
    }
    
    function viewSalary() public view returns (uint32) {
        return salary;
    }

    error TooManyShares(uint16 _shares);
    
    function grantShares(uint16 _newShares) public {
        if (_newShares > 5000) {
            revert("Too many shares");
        } else if (shares + _newShares > 5000) {
            revert TooManyShares(shares + _newShares);
        }
        shares += _newShares;
    }

    function checkForPacking(uint _slot) public view returns (uint r) {
        assembly {
            r := sload(_slot)
        }
    }

    function debugResetShares() public {
        shares = 1000;
    }
}
