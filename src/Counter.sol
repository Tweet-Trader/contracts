// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {IERC20} from "openzeppelin/interfaces/IERC20.sol";
import {IUniswapV2Router02} from "v2-periphery/interfaces/IUniswapV2Router02.sol";
import {ISwapRouter} from "v3-periphery/interfaces/ISwapRouter.sol";

contract TwitterBot {
    IUniswapV2Router02 public immutable v2Router;
    ISwapRouter public immutable v3Router;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    constructor() {
        v2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        v3Router = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    }

    function buyTokens_v2Router(address tokenAddress, uint256 amountIn, uint256 amountOutMin) external {
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

        token.approve(address(v2Router), amountIn);

        address[] memory path = new address[](2);
        path[0] = tokenAddress;
        path[1] = WETH;
        v2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountIn, amountOutMin, path, msg.sender, block.timestamp
        );
    }

    function buyTokens_v3Router(address tokenAddress, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)
        external
    {
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: WETH,
            tokenOut: tokenAddress,
            fee: poolFee,
            recipient: msg.sender,
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin,
            sqrtPriceLimitX96: 0
        });

        v3Router.exactInputSingle(params);
    }

    function sellTokens_v3Router(address tokenAddress, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)
        external
    {
        IERC20 token = IERC20(tokenAddress);

        token.approve(address(v2Router), amountIn);

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
}
