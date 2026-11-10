import { Module } from '@nestjs/common';
import { PrismaService } from '../../prisma.service';
import { ComplianceController } from './compliance.controller';
import { ComplianceService } from './compliance.service';

@Module({
  controllers: [ComplianceController],
  providers: [ComplianceService, PrismaService],
  exports: [ComplianceService],
})
export class ComplianceModule {}
