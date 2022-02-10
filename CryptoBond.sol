// SPDX-Licence-Identifier: MIT
pragma solidity >=0.8.0;

// To be used in Rinkeby Testnet
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract CryptoBond {

    mapping(address => uint256) public addressToAmountFunded;
    address owner;

    constructor() public {
        owner = msg.sender;
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (, int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 10 ** 10); // 1 Wei = 18 decimal points
    }

    function getConversionRate(uint256 _ethAmount) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUSD = (ethPrice * _ethAmount) / (10 ** 18); // Matching units
        return ethAmountInUSD;
    }

    // payable function - this function can be associated with ETH payments
    function fund() public payable {
        // Minimum amount to participate = $10
        uint256 minimumUSD = 10 * 10 ** 18;
        require(getConversionRate(msg.value) >= minimumUSD, "You need to spend more ETH!"); // reverts the transaction and sends money back
        addressToAmountFunded[msg.sender] += msg.value;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You are not allowed to perform the action!");
        _;
    }

    function withdrawPool() public onlyOwner payable {
        payable(msg.sender).transfer(address(this).balance);
    }

    function poolBalance() public view returns (uint256) {
        return address(this).balance;
    }

}