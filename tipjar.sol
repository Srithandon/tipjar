// SPDX-License-Identifier: MIT
pragma solidity 0.8.31; // ปรับเป็นเวอร์ชันมาตรฐาน (หรือ 0.8.31 ตามเดิมได้ครับ)

contract tips {
    address owner;

    struct Waitress {
        address payable walletAddress;
        string name;
        uint percent;
    }

    Waitress[] public waitress;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    function addtips() payable public {}

    function viewtips() public view returns(uint) {
        return address(this).balance;
    }

    function viewWaitress() public view returns(Waitress[] memory) {
        return waitress;
    }

    // ฟังก์ชันช่วยคำนวณเปอร์เซ็นต์รวมทั้งหมดในปัจจุบัน
    function getTotalPercent() public view returns(uint) {
        uint total = 0;
        for(uint i = 0; i < waitress.length; i++) {
            total += waitress[i].percent;
        }
        return total;
    }

    function addWaitress(address payable walletAddress, string memory name, uint percent) public onlyOwner {
        // 1. ตรวจสอบว่าถ้าเพิ่มคนนี้แล้ว เปอร์เซ็นต์รวมจะเกิน 100 หรือไม่
        uint currentTotal = getTotalPercent();
        require(currentTotal + percent <= 100, "Total percent exceeds 100%");

        // 2. ตรวจสอบว่า Address นี้มีอยู่แล้วหรือไม่
        for(uint i = 0; i < waitress.length; i++) {
            require(waitress[i].walletAddress != walletAddress, "Waitress already exists");
        }

        // 3. เพิ่มข้อมูล
        waitress.push(Waitress(walletAddress, name, percent));
    }

    function removeWaitress(address walletAddress) public onlyOwner {
        for(uint i = 0; i < waitress.length; i++){
            if(waitress[i].walletAddress == walletAddress){
                // เลื่อนตำแหน่งเพื่อลบ
                for (uint j = i; j < waitress.length - 1; j++) {
                    waitress[j] = waitress[j + 1];
                }
                waitress.pop();
                return; // ออกจากฟังก์ชันทันทีเมื่อลบเสร็จ
            }
        }
    }

    function distributeBalance() public {
        uint totalBalance = address(this).balance;
        require(totalBalance > 0, "No Money");
        require(waitress.length > 0, "No Waitress added");

        for(uint j = 0; j < waitress.length; j++){
            uint distributeAmount = (totalBalance * waitress[j].percent) / 100;
            
            if (distributeAmount > 0) {
                _transferFunds(waitress[j].walletAddress, distributeAmount);
            }
        }
    }

    function _transferFunds(address payable recipient, uint amount) internal {
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Transfer failed.");  
    }
}