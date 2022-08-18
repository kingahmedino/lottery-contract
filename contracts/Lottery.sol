// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Lottery is ERC721URIStorage, ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    Counters.Counter private _lotteryIds;
    mapping(uint256 => Ticket) private idToTicket;

    struct Ticket {
        uint256 tokenId;
        address payable bearer;
    }

    event TicketCreated(uint256 indexed tokenId, address indexed bearer);

    constructor() ERC721("Lottery Tokens", "LTK") {}

    function enter() public payable nonReentrant {
        require(msg.sender != owner(), "Owner cannot enter the lottery");
        require(
            msg.value > 0.01 ether,
            "Enterance fee must be greater than 0.01 ether"
        );

        //create a token
        uint256 newTokenId = createToken("");

        //create a mapping for it
        idToTicket[newTokenId] = Ticket({
            tokenId: newTokenId,
            bearer: payable(msg.sender)
        });

        emit TicketCreated(newTokenId, msg.sender);
    }

    function pickWinner() public onlyOwner {
        require(
            _lotteryIds.current() > 1,
            "There are not enough players to pick a winner from"
        );
        uint256 randomId = getRandomNumber() % _lotteryIds.current();
        address payable winner = idToTicket[randomId].bearer;

        winner.transfer(address(this).balance);
    }

    function getBearers() public view returns (address[] memory) {
        address[] memory bearers = new address[](_lotteryIds.current());

        for (uint256 id = 0; id < _lotteryIds.current(); id++) {
            bearers[id + 1] = idToTicket[id + 1].bearer;
        }

        return bearers;
    }

    function createToken(string memory tokenURI) internal returns (uint256) {
        _lotteryIds.increment();
        uint256 newTokenId = _lotteryIds.current();

        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        return newTokenId;
    }

    function getRandomNumber() internal view returns (uint256 num) {
        num = uint256(keccak256(abi.encodePacked(owner(), block.timestamp)))
            .add(1);
    }
}
