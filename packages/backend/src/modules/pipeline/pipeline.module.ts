import { Module } from '@nestjs/common';
import { PrismaService } from '../../prisma.service';
import { AIProviderModule } from '../ai-provider/ai-provider.module';
import { ComplianceModule } from '../compliance/compliance.module';
import { ModerationModule } from '../moderation/moderation.module';
import { WalletModule } from '../wallet/wallet.module';
import { PipelineController } from './pipeline.controller';
import { PipelineService } from './pipeline.service';

@Module({
  imports: [AIProviderModule, WalletModule, ComplianceModule, ModerationModule],
  controllers: [PipelineController],
  providers: [PipelineService, PrismaService],
  exports: [PipelineService],
})
export class PipelineModule {}
