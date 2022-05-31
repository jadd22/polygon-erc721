// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IERC165.sol";


interface IERC721Permit is IERC165 {

    function permit(address _approver, uint256 _tokenId, uint256 _expireTime, bytes memory _sig) external;

    function nonces(uint256 _tokenId) external view returns(uint256);

    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns(bytes32);

}