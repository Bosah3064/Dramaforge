import { Module } from '@nestjs/common';
import { PrismaService } from '../../prisma.service';
import { AIProviderModule } from '../ai-provider/ai-provider.module';
import { ComplianceModule } from '../compliance/compliance.module';
import { ModerationModule } from '../moderation/moderation.module';
import { WalletModule } from '../wallet/wallet.module';
import { EffectsController } from './effects.controller';
import { EffectsService } from './effects.service';

@Module({
  imports: [AIProviderModule, WalletModule, ComplianceModule, ModerationModule],
  controllers: [EffectsController],
  providers: [EffectsService, PrismaService],
  exports: [EffectsService],
})
export class EffectsModule {}
