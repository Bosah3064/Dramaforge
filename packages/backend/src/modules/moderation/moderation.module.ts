import { Module } from '@nestjs/common';
import { PrismaService } from '../../prisma.service';
import { ModerationService } from './moderation.service';

@Module({
  providers: [ModerationService, PrismaService],
  exports: [ModerationService],
})
export class ModerationModule {}
