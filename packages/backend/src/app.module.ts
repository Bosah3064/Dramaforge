import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaService } from './prisma.service';
import { AdminModule } from './modules/admin/admin.module';
import { AIProviderModule } from './modules/ai-provider/ai-provider.module';
import { AuthModule } from './modules/auth/auth.module';
import { BillingModule } from './modules/billing/billing.module';
import { ComplianceModule } from './modules/compliance/compliance.module';
import { EffectsModule } from './modules/effects/effects.module';
import { ModerationModule } from './modules/moderation/moderation.module';
import { PipelineModule } from './modules/pipeline/pipeline.module';
import { ProjectsModule } from './modules/projects/projects.module';
import { WalletModule } from './modules/wallet/wallet.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env', '../../.env'],
    }),
    AuthModule,
    WalletModule,
    ComplianceModule,
    ModerationModule,
    AIProviderModule,
    ProjectsModule,
    PipelineModule,
    EffectsModule,
    BillingModule,
    AdminModule,
  ],
  providers: [PrismaService],
  exports: [PrismaService],
})
export class AppModule {}
