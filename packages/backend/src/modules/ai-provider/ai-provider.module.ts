import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { MockAIAdapter } from './adapters/mock-ai.adapter';
import { RealAIAdapter } from './adapters/real-ai.adapter';
import { AIProviderService } from './ai-provider.service';

@Module({
  imports: [ConfigModule],
  providers: [MockAIAdapter, RealAIAdapter, AIProviderService],
  exports: [AIProviderService],
})
export class AIProviderModule {}
