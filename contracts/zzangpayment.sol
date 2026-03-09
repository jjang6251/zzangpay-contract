// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract ZzangPayPayment {

    IERC20 public immutable zusdc;
    IERC20Permit public immutable zusdcPermit;

    //replay attack(재사용 공격)을 막기 위한 nonce
    mapping(address => uint256) public nonces;

    event Paid(
        address indexed payer,
        address indexed merchant,
        uint256 amount,
        uint256 nonce
    );

    constructor(address zusdcAddress) {
        zusdc = IERC20(zusdcAddress);
        zusdcPermit = IERC20Permit(zusdcAddress);
    }

    function payWithPermit(
        address payer,
        address merchant,
        uint256 amount,
        uint256 deadline,
        uint8 permitV,
        bytes32 permitR,
        bytes32 permitS,
        bytes calldata paymentSignature
    ) external {
        require(block.timestamp <= deadline, "payment expired");
        require(merchant != address(0), "invalid merchant");
        require(amount > 0, "invalid amount");

        uint256 currentNonce = nonces[payer];

        // 사용자 결제 의사 검증
        bytes32 messageHash = keccak256(
            abi.encodePacked(
                address(this),
                block.chainid,
                payer,
                merchant,
                amount,
                currentNonce,
                deadline
            )
        );

        bytes32 ethSignedHash = MessageHashUtils.toEthSignedMessageHash(messageHash);
        address recovered = ECDSA.recover(ethSignedHash, paymentSignature);

        require(recovered == payer, "invalid signature");

        // permit 실행 (allowance 설정)
        zusdcPermit.permit(
            payer,
            address(this),
            amount,
            deadline,
            permitV,
            permitR,
            permitS
        );

        // merchant에게 토큰 전송
        bool success = zusdc.transferFrom(payer, merchant, amount);
        require(success, "transfer failed");

        nonces[payer] = currentNonce + 1;

        emit Paid(payer, merchant, amount, currentNonce);
    }

    function getMessageHash(
        address payer,
        address merchant,
        uint256 amount,
        uint256 nonce,
        uint256 deadline
    ) external view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                address(this),
                block.chainid,
                payer,
                merchant,
                amount,
                nonce,
                deadline
            )
        );
    }
}