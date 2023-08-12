// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {IERC20} from "openzeppelin/interfaces/IERC20.sol";
import {IUniswapRouter02} from "v2-periphery/interfaces/IUniswapV2Router02.sol";
import {ISwapRouter} from "v3-periphery/interfaces/ISwapRouter.sol";

contract TwitterBot {
    IUniswapRouter02 public v2Router;
    ISwapRouter public v3Router;

    constructor() {
        v2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        v3Router = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    }

    function buyTokens_v2Router(address tokenAddress, uint256 amountIn, uint256 amountOutMin) external {
        IERC20 token = IERC20(tokenAddress);

        token.approve(address(UniswapV2Router02), amountIn);

        // amountOutMin must be retrieved from an oracle of some kind
        address[] memory path = new address[](2);
        path[0] = UniswapV2Router02.WETH();
        path[1] = tokenAddress;
        UniswapV2Router02.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountIn}(
            amountOutMin, path, msg.sender, block.timestamp
        );
    }

    function sellTokens_v2Router(address tokenAddress, uint256 amountOutMin) external {
        IERC20 token = IERC20(tokenAddress);

        token.approve(address(UniswapV2Router02), amountIn);

        address[] memory path = new address[](2);
        path[0] = tokenAddress;
        path[1] = UniswapV2Router02.WETH();
        UniswapV2Router02.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountIn, amountOutMin, path, msg.sender, block.timestamp
        );
    }
}
