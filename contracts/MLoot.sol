// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract MLoot is ERC721, ERC721Enumerable, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
//    string public baseURI;
    string public baseURI="https://www.mlootproject.com/mloot/";
    uint256 public mintPrice = 0.01 ether;

    uint256 public constant maxSupply = 10000;
    uint256 private _reserved = 500;
    uint256 private maxClaimCount = 5;

    function setClaimCount(uint256 cnt) external onlyOwner {
        maxClaimCount = cnt;
    }

    function setBaseURI(string memory _URI) external onlyOwner {
        baseURI = _URI;
    }

    function _baseURI() internal view override(ERC721) returns(string memory) {
        return baseURI;
    }

    function withdraw() public onlyOwner {
        uint256 _balance = address(this).balance;
        require(payable(owner()).send(_balance));
    }

    // mint from website
    function mint(uint256 _nTokens) public payable nonReentrant {
        uint256 supply = totalSupply();
        require(_nTokens < 21, "You cannot mint more than 20 Tokens at once!");
        require(supply + _nTokens <= maxSupply - _reserved, "Not enough Tokens left.");
        require(_nTokens * mintPrice <= msg.value, "Inconsistent amount sent!");

        for (uint256 i; i < _nTokens; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    function claim() public nonReentrant returns (uint256) {
        uint256 supply = totalSupply();
        require(balanceOf(_msgSender()) < maxClaimCount, "One account can not claim more than 3 mloots");
        require(supply + _reserved < maxSupply, "MLoots have been sold out.");
        _safeMint(_msgSender(), supply+1);
        return balanceOf(_msgSender());
    }

    function claimReserved(uint256 _number, address _receiver) external onlyOwner {
        require(_number <= _reserved, "That would exceed the max reserved.");

        uint256 _tokenId = totalSupply();
        for (uint256 i; i < _number; i++) {
            _safeMint(_receiver, _tokenId + i);
        }

        _reserved = _reserved - _number;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    constructor() ERC721("MLoot", "MLOOT") {}
}
