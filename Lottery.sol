// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2plus.sol";
import "@chainlink/contracts/src/v0.8/vrf/dev/libraries/IVRFCoordinatorV2plus.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract VerifiableLottery is VRFConsumerBaseV2plus, ReentrancyGuard {
    enum LotteryState { OPEN, CALCULATING, CLOSED }

    uint256 public constant TICKET_PRICE = 0.01 ether;
    address[] public players;
    LotteryState public state;
    
    // VRF Variables (Example: Sepolia)
    uint256 public s_subscriptionId;
    bytes32 public keyHash = 0x816535a56347107319717b966ed71d536c6418870ed20b925b4be461f3a9e105;
    uint32 public callbackGasLimit = 100000;
    
    address public lastWinner;

    event TicketPurchased(address indexed player);
    event WinnerPicked(address indexed winner, uint256 amount);

    constructor(uint256 subscriptionId, address vrfCoordinator) 
        VRFConsumerBaseV2plus(vrfCoordinator) 
    {
        s_subscriptionId = subscriptionId;
        state = LotteryState.OPEN;
    }

    function enter() external payable {
        require(state == LotteryState.OPEN, "Lottery not open");
        require(msg.value >= TICKET_PRICE, "Insufficient ETH");
        players.push(msg.sender);
        emit TicketPurchased(msg.sender);
    }

    function endLottery() external onlyOwner {
        require(state == LotteryState.OPEN, "Already calculating");
        state = LotteryState.CALCULATING;
        
        s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: s_subscriptionId,
                requestConfirmations: 3,
                callbackGasLimit: callbackGasLimit,
                numWords: 1,
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
            })
        );
    }

    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override {
        require(state == LotteryState.CALCULATING, "Not in calculation mode");
        
        uint256 indexOfWinner = randomWords[0] % players.length;
        address winner = players[indexOfWinner];
        uint256 prize = address(this).balance;

        lastWinner = winner;
        players = new address[](0);
        state = LotteryState.OPEN;

        (bool success, ) = winner.call{value: prize}("");
        require(success, "Payout failed");
        
        emit WinnerPicked(winner, prize);
    }
}
