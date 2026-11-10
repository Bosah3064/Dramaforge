import { Module } from '@nestjs/common';
import { PrismaService } from '../../prisma.service';
import { AIProviderModule } from '../ai-provider/ai-provider.module';
import { WalletModule } from '../wallet/wallet.module';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';

@Module({
  imports: [WalletModule, AIProviderModule],
  controllers: [AdminController],
  providers: [AdminService, PrismaService],
  exports: [AdminService],
})
export class AdminModule {}
