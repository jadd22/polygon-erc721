// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC712.sol";
// import ".inter .sol";
import "./interface/IERC721.sol";
import "./interface/IERC721Permit.sol";

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";

contract ERC721Permit is ERC721, ERC712, IERC721Permit {
    using Counters for Counters.Counter;

    // solhint-disable-next-line func-name-mixedcase
    bytes32 private immutable _PERMIT_TYPEHASH =
        keccak256(
            "Permit(address _approver,uint256 _tokenId,uint256 _nonce,uint256 _expireTime)"
        );

    constructor(string memory name, string memory symbol)
        ERC721(name, symbol)
        ERC712(name, "1")
    {
        this;
    }

    mapping(uint256 => Counters.Counter) private _nonces;

    function nonces(uint256 tokenId)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return _nonces[tokenId].current();
    }

    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        bytes memory signature
    ) external override {
        _permit(spender, tokenId, deadline, signature);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        _nonces[tokenId].increment();
        super._transfer(from, to, tokenId);
    }

    function _permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        bytes memory signature
    ) internal virtual {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp <= deadline, "ERC721Permit: expired deadline");

        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                spender,
                tokenId,
                _nonces[tokenId].current(),
                deadline
            )
        );
        bytes32 hash = _hashTypedDataV4(structHash);

        (address signer, ) = ECDSA.tryRecover(hash, signature);
        require(signer != address(0), "ZERO Address");

        address ownerOfToken = super.ownerOf(tokenId);
        require(
            _isValidContractERC1271Signature(ownerOfToken, hash, signature) ||
                _isValidContractERC1271Signature(
                    super.getApproved(tokenId),
                    hash,
                    signature
                ),
            "ERC721Permit: invalid signature"
        );

        _approve(spender, tokenId);
    }

    function _isValidContractERC1271Signature(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {
        (bool success, bytes memory result) = signer.staticcall(
            abi.encodeWithSelector(
                IERC1271.isValidSignature.selector,
                hash,
                signature
            )
        );
        return (success &&
            result.length == 32 &&
            abi.decode(result, (bytes4)) == IERC1271.isValidSignature.selector);
    }
}
