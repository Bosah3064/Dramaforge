import { Body, Controller, Headers, Post, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { BillingService, RevenueCatWebhookPayload } from './billing.service';

@ApiTags('Billing & In-App Purchases')
@Controller('billing')
export class BillingController {
  constructor(
    private readonly billingService: BillingService,
    private readonly configService: ConfigService,
  ) {}

  @Post('webhook/revenuecat')
  @ApiOperation({ summary: 'RevenueCat Webhook for Subscriptions and Consumable Coin Packs' })
  @ApiResponse({ status: 200, description: 'Event processed' })
  async handleWebhook(
    @Headers('Authorization') authHeader: string,
    @Body() payload: RevenueCatWebhookPayload,
  ) {
    const expectedToken = this.configService.get<string>('REVENUECAT_WEBHOOK_AUTH_TOKEN', 'revcat_secret_token_123');
    if (authHeader && authHeader !== `Bearer ${expectedToken}` && authHeader !== expectedToken) {
      throw new UnauthorizedException('Invalid webhook token');
    }

    return this.billingService.handleRevenueCatEvent(payload);
  }
}
