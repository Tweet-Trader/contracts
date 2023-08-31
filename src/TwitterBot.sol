// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {IERC20} from "openzeppelin/interfaces/IERC20.sol";
import {IUniswapV2Router02} from "v2-periphery/interfaces/IUniswapV2Router02.sol";
import {ISwapRouter} from "v3-periphery/interfaces/ISwapRouter.sol";
import {console} from "forge-std/console.sol";

contract TwitterBot {
    IUniswapV2Router02 private immutable v2Router;
    ISwapRouter private immutable v3Router;
    address private immutable WETH;
    address private owner;

    uint256 private teamFee = 5;
    uint256 private constant denominator = 1000;

    error EthTransferFailed();
    error notOwner();

    modifier onlyOwner() {
        if (msg.sender != owner) revert notOwner();
        _;
    }

    constructor() {
        v2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        v3Router = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
        WETH = v2Router.WETH();
    }

    function buyTokens_v2Router(address tokenAddress, uint256 amountOutMin) external payable {
        uint256 amountIn = msg.value * (denominator - teamFee) / denominator;

        // amountOutMin must be retrieved from an oracle of some kind
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = tokenAddress;
        v2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountIn}(
            amountOutMin, path, msg.sender, block.timestamp
        );
    }

    function sellTokens_v2Router(address tokenAddress, uint256 amountIn, uint256 amountOutMin) external {
        IERC20 token = IERC20(tokenAddress);
        token.transferFrom(msg.sender, address(this), amountIn);
        token.approve(address(v2Router), amountIn);

        uint256 initialBalance = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = tokenAddress;
        path[1] = WETH;
        v2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountIn, amountOutMin, path, address(this), block.timestamp
        );

        // 0.5% fee
        uint256 amountOut = (address(this).balance - initialBalance) * (denominator - teamFee) / denominator;
        (bool success,) = msg.sender.call{value: amountOut}("");
        if (!success) revert EthTransferFailed();
    }

    function buyTokens_v3Router(address tokenAddress, uint256 amountOutMin, uint24 poolFee) external payable {
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: WETH,
            tokenOut: tokenAddress,
            fee: poolFee,
            recipient: msg.sender,
            deadline: block.timestamp,
            amountIn: msg.value,
            amountOutMinimum: amountOutMin,
            sqrtPriceLimitX96: 0
        });

        v3Router.exactInputSingle(params);
    }

    function sellTokens_v3Router(address tokenAddress, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)
        external
    {
        IERC20 token = IERC20(tokenAddress);
        token.transferFrom(msg.sender, address(this), amountIn);
        token.approve(address(v3Router), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenAddress,
            tokenOut: WETH,
            fee: poolFee,
            recipient: msg.sender,
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin,
            sqrtPriceLimitX96: 0
        });

        v3Router.exactInputSingle(params);
    }

    function withdraw() external payable onlyOwner {
        (bool success,) = payable(owner).call{value: address(this).balance}("");
        if (!success) revert EthTransferFailed();
    }

    function changeOwner() external payable onlyOwner {
        owner = msg.sender;
    }

    receive() external payable {}
}
