// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

interface ISubmission {
    struct Haiku {
        address author;
        string line1;
        string line2;
        string line3;
    }

    function mintHaiku(
        string memory _line1,
        string memory _line2,
        string memory _line3
    ) external;

    function counter() external view returns (uint256);

    function shareHaiku(uint256 _id, address _to) external;

    function getMySharedHaikus() external view returns (Haiku[] memory);
}

contract HaikuNFT is ERC721, ISubmission {
    Haiku[] public haikus;
    mapping(address => mapping(uint256 => bool)) public sharedHaikus;
    uint256 public haikuCounter;

    constructor() ERC721("HaikuNFT", "HAIKU") {
        haikuCounter = 1;
    }

    string salt = "value";

    function counter() external view override returns (uint256) {
        return haikuCounter;
    }

    function mintHaiku(
        string memory _line1,
        string memory _line2,
        string memory _line3
    ) external override {
        string[3] memory haikusStrings = [_line1, _line2, _line3];
        for (uint256 li = 0; li < haikusStrings.length; li++) {
            string memory newLine = haikusStrings[li];
            for (uint256 i = 0; i < haikus.length; i++) {
                Haiku memory existingHaiku = haikus[i];
                string[3] memory existingHaikuStrings = [
                    existingHaiku.line1,
                    existingHaiku.line2,
                    existingHaiku.line3
                ];
                for (uint256 eHsi = 0; eHsi < 3; eHsi++) {
                    string memory existingHaikuString = existingHaikuStrings[eHsi];
                    if (
                        keccak256(abi.encodePacked(existingHaikuString)) ==
                        keccak256(abi.encodePacked(newLine))
                    ) {
                        revert HaikuNotUnique();
                    }
                }
            }
        }

        _safeMint(msg.sender, haikuCounter);
        haikus.push(Haiku(msg.sender, _line1, _line2, _line3));
        haikuCounter++;
    }

    function shareHaiku(uint256 _id, address _to) external override {
        require(_id > 0 && _id <= haikuCounter, "Invalid haiku ID");

        Haiku memory haikuToShare = haikus[_id - 1];
        require(haikuToShare.author == msg.sender, "NotYourHaiku");

        sharedHaikus[_to][_id] = true;
    }

    function getMySharedHaikus() external view override returns (Haiku[] memory) {
        uint256 sharedHaikuCount;
        for (uint256 i = 0; i < haikus.length; i++) {
            if (sharedHaikus[msg.sender][i + 1]) {
                sharedHaikuCount++;
            }
        }

        Haiku[] memory result = new Haiku[](sharedHaikuCount);
        uint256 currentIndex;
        for (uint256 i = 0; i < haikus.length; i++) {
            if (sharedHaikus[msg.sender][i + 1]) {
                result[currentIndex] = haikus[i];
                currentIndex++;
            }
        }

        if (sharedHaikuCount == 0) {
            revert NoHaikusShared();
        }

        return result;
    }

    error HaikuNotUnique();
    error NotYourHaiku();
    error NoHaikusShared();
}
