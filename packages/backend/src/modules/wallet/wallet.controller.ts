import { Controller, Get, Query, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { CoinLedgerItemDto, WalletBalanceDto } from 'dramaforge-shared';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { WalletService } from './wallet.service';

@ApiTags('Wallet & Coins')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('wallet')
export class WalletController {
  constructor(private readonly walletService: WalletService) {}

  @Get('balance')
  @ApiOperation({ summary: 'Get current user dual-bucket coin balance' })
  @ApiResponse({ status: 200, description: 'Dual-bucket wallet balance' })
  async getBalance(@Req() req: any): Promise<WalletBalanceDto> {
    return this.walletService.getBalance(req.user.id);
  }

  @Get('ledger')
  @ApiOperation({ summary: 'Get immutable coin transaction history' })
  @ApiResponse({ status: 200, description: 'Ledger history list' })
  async getLedgerHistory(
    @Req() req: any,
    @Query('limit') limit = 50,
  ): Promise<CoinLedgerItemDto[]> {
    return this.walletService.getLedgerHistory(req.user.id, Number(limit));
  }
}
