// <copyright file="ImplicitUseTargetFlags.cs" company="JetBrains s.r.o.">
// Copyright 2007-2012 JetBrains s.r.o.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// </copyright>

namespace JetBrains.Annotations
{
    using System;
    using System.Diagnostics.CodeAnalysis;

    /// <summary>Specify what is considered used implicitly when marked with <see cref="MeansImplicitUseAttribute"/> or <see cref="UsedImplicitlyAttribute"/></summary>
    [Flags]
    [SuppressMessage("Microsoft.Naming", "CA1726:UsePreferredTerms", MessageId = "Flags", Justification = "Jetbrains code")]
    public enum ImplicitUseTargetFlags
    {
        [SuppressMessage("StyleCop.CSharp.DocumentationRules", "SA1602:EnumerationItemsMustBeDocumented", Justification = "Jetbrains code")]
        Default = Itself,

        [SuppressMessage("StyleCop.CSharp.DocumentationRules", "SA1602:EnumerationItemsMustBeDocumented", Justification = "Jetbrains code")]
        Itself = 1,

        /// <summary>Members of entity marked with attribute are considered used</summary>
        Members = 2,

        /// <summary>Entity marked with attribute and all its members considered used</summary>
        WithMembers = Itself | Members
    }
}