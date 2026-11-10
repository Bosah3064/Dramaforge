import { Body, Controller, Delete, Get, Ip, Post, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ComplianceService, ConsentSubmissionDto } from './compliance.service';

@ApiTags('Compliance, Safety & Privacy')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('compliance')
export class ComplianceController {
  constructor(private readonly complianceService: ComplianceService) {}

  @Post('consent')
  @ApiOperation({ summary: 'Submit pre-transfer third-party AI consent acknowledgment' })
  @ApiResponse({ status: 201, description: 'Consent recorded successfully' })
  async recordConsent(
    @Req() req: any,
    @Body() dto: ConsentSubmissionDto,
    @Ip() ip: string,
  ) {
    return this.complianceService.recordConsent(req.user.id, dto, ip);
  }

  @Get('consent/status')
  @ApiOperation({ summary: 'Check if user has acknowledged the pre-transfer consent' })
  async getConsentStatus(@Req() req: any) {
    const hasConsent = await this.complianceService.hasConsent(req.user.id);
    return { hasConsent };
  }

  @Get('export-data')
  @ApiOperation({ summary: 'Export all personal and project data (GDPR Article 20)' })
  async exportData(@Req() req: any) {
    return this.complianceService.exportUserData(req.user.id);
  }

  @Delete('delete-account')
  @ApiOperation({ summary: 'Permanently delete account and all media (GDPR Right to Erasure)' })
  async deleteAccount(@Req() req: any) {
    return this.complianceService.deleteUserAccount(req.user.id);
  }
}
